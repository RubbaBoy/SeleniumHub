import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

final RegExp _straySlashes = RegExp(r'(^/+)|(/+$)');
final MediaType _fallbackMediaType = MediaType('application', 'octet-stream');

// Code adapted from angel_proxy https://pub.dev/packages/angel_proxy under MIT license.
class Proxy {
  String _prefix;

  final http.BaseClient httpClient;
  final String toUri;

  /// If `true` (default), then the plug-in will ignore failures to connect to the proxy, and allow other handlers to run.
  final bool recoverFromDead;
  final bool recoverFrom404;
  final String publicPath;

  /// If `null` then no timout is added for requests
  final Duration timeout;

  WebSocket local;
  WebSocket remote;

  Proxy(
      this.httpClient,
      this.toUri, {
        this.publicPath = '/',
        this.recoverFromDead = true,
        this.recoverFrom404 = true,
        this.timeout,
      }) {
    if (this.recoverFromDead == null)
      throw ArgumentError.notNull("recoverFromDead");
    if (this.recoverFrom404 == null)
      throw ArgumentError.notNull("recoverFrom404");
    _prefix = publicPath?.replaceAll(_straySlashes, '') ?? '';
  }

  void close() {
    local?.close();
    remote?.close();
    httpClient?.close();
  }

  /// Handles an incoming HTTP request.
  Future<bool> handleRequest(RequestContext req, ResponseContext res) {
    var path = req.path.replaceAll(_straySlashes, '');

    if (_prefix.isNotEmpty) {
      if (!p.isWithin(_prefix, path) && !p.equals(_prefix, path)) {
        return Future<bool>.value(true);
      }

      path = p.relative(path, from: _prefix);
    }

    return servePath(path, req, res);
  }

  /// Proxies a request to the given path on the remote server.
  Future<bool> servePath(
      String path, RequestContext req, ResponseContext res) async {
    http.StreamedResponse rs;

    var thisUri = Uri.parse(toUri);
    var uri = thisUri.replace(path: thisUri.path + path.substring(42));
    print(thisUri.path);
    print(path);
    print(uri);

    try {
      if (req is HttpRequestContext &&
          WebSocketTransformer.isUpgradeRequest(req.rawRequest)) {
        res.detach();
        uri = uri.replace(scheme: uri.scheme == 'https' ? 'wss' : 'ws');

        try {
          local = await WebSocketTransformer.upgrade(req.rawRequest);
          remote = await WebSocket.connect(uri.toString());

          scheduleMicrotask(() => local.pipe(remote));
          scheduleMicrotask(() => remote.pipe(local));
          return false;
        } catch (e, st) {
          throw AngelHttpException(e,
              message: 'Could not connect WebSocket', stackTrace: st);
        }
      }

      Future<http.StreamedResponse> accessRemote() async {
        var headers = <String, String>{
          'host': uri.authority,
          'x-forwarded-for': req.remoteAddress.address,
          'x-forwarded-port': req.uri.port.toString(),
          'x-forwarded-host':
          req.headers.host ?? req.headers.value('host') ?? 'none',
          'x-forwarded-proto': uri.scheme,
        };

        req.headers.forEach((name, values) {
          headers[name] = values.join(',');
        });

        headers[HttpHeaders.cookieHeader] =
            req.cookies.map<String>((c) => '${c.name}=${c.value}').join('; ');

        List<int> body;

        if (!req.hasParsedBody) {
          body = await req.body
              .fold<BytesBuilder>(BytesBuilder(), (bb, buf) => bb..add(buf))
              .then((bb) => bb.takeBytes());
        }

        var rq = http.Request(req.method, uri);
        rq.headers.addAll(headers);
        rq.headers['host'] = rq.url.host;
        rq.encoding = Utf8Codec(allowMalformed: true);

        if (body != null) rq.bodyBytes = body;

        return httpClient.send(rq);
      }

      var future = accessRemote();
      if (timeout != null) future = future.timeout(timeout);
      rs = await future;
    } on TimeoutException catch (e, st) {
      if (recoverFromDead) return true;

      throw AngelHttpException(
        e,
        stackTrace: st,
        statusCode: 504,
        message:
        'Connection to remote host "$uri" timed out after ${timeout.inMilliseconds}ms.',
      );
    } catch (e) {
      if (recoverFromDead && e is! AngelHttpException) return true;
      rethrow;
    }

    if (rs.statusCode == 404 && recoverFrom404) return true;
    if (rs.contentLength == 0 && recoverFromDead) return true;

    MediaType mediaType;
    if (rs.headers.containsKey(HttpHeaders.contentTypeHeader)) {
      try {
        mediaType = MediaType.parse(rs.headers[HttpHeaders.contentTypeHeader]);
      } on FormatException catch (e, st) {
        if (recoverFromDead) return true;

        throw AngelHttpException(
          e,
          stackTrace: st,
          statusCode: 504,
          message: 'Host "$uri" returned a malformed content-type',
        );
      }
    } else {
      mediaType = _fallbackMediaType;
    }

    /// if [http.Client] does not provide us with a content length
    /// OR [http.Client] is about to decode the response (bytecount returned by [http.Response].stream != known length)
    /// then we can not provide a value downstream => set to '-1' for 'unspecified length'
    var isContentLengthUnknown = rs.contentLength == null ||
        rs.headers[HttpHeaders.contentEncodingHeader]?.isNotEmpty == true ||
        rs.headers[HttpHeaders.transferEncodingHeader]?.isNotEmpty == true;

    var proxiedHeaders = Map<String, String>.from(rs.headers)
      ..remove(
          HttpHeaders.contentEncodingHeader) // drop, http.Client has decoded
      ..remove(
          HttpHeaders.transferEncodingHeader) // drop, http.Client has decoded
      ..[HttpHeaders.contentLengthHeader] =
          "${isContentLengthUnknown ? '-1' : rs.contentLength}";

    res
      ..contentType = mediaType
      ..statusCode = rs.statusCode
      ..headers.addAll(proxiedHeaders);

    await rs.stream.pipe(res);

    return false;
  }
}