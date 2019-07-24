import 'dart:io';
import 'dart:mirrors';

import 'package:mime/mime.dart';

import 'Requestable.dart';
import 'api.dart';

Map<String, Requestable> DART_FILES = {
  "api": API()
};

Future<void> runServer(String basePath) async {
  final server = await HttpServer.bind('127.0.0.1', 6969);
  await for (HttpRequest request in server) {
    await handleRequest(basePath, request);
  }
}

Future<void> handleRequest(String basePath, HttpRequest request) async {
  final String path = request.uri.path;
  final String resultPath = path == '/' || path == '\\' ? '\\index.html' : path;
  final File file = File('$basePath$resultPath');
  if (await file.exists()) {
    try {
      var mime = lookupMimeType(resultPath);
      var contentType = ContentType(mime.split("/")[0], mime.split("/")[1]);

      var response = request.response
        ..headers.contentType = contentType;
      await response.addStream(file.openRead());
      await response.close();
    } catch (exception) {
      print('Error happened: $exception');
      await sendInternalError(request.response);
    }
  } else if (getDartFile(path) != null) {
    var dartInstance = getDartFile(path);
    var response = request.response
      ..headers.contentType = dartInstance.getContentType();
    await response.write(dartInstance.request(request.uri.queryParameters));
    await response.close();
  } else {
    await sendNotFound(request.response);
  }
}

Requestable getDartFile(String query) {
  return DART_FILES[query.replaceFirst('\\', '').replaceFirst('/', '')];
}

Map<String, String> getQueryParams(HttpRequest request) {
  var splitQuery = request.requestedUri.toString().split('?');
  if (splitQuery.length == 1) return {};
  var map = {};
  splitQuery[0].split('&').forEach((kv) {
    var kvSplit = kv.split('=');
    map[kvSplit[0]] = kvSplit[1];
  });
  return map;
}

Future<void> sendInternalError(HttpResponse response) async {
  response.statusCode = HttpStatus.internalServerError;
  await response.close();
}

Future<void> sendNotFound(HttpResponse response) async {
  response.statusCode = HttpStatus.notFound;
  await response.close();
}

Future<void> main(List<String> args) async => await runServer(args.isNotEmpty ? args[0] : File(Platform.script.toFilePath()).parent.path);
