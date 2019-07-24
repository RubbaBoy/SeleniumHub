import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:mime/mime.dart';

import 'instance_manager.dart';
import 'requestable.dart';
import 'api.dart';
import 'selenium_proxy.dart';

InstanceManager instanceManager = InstanceManager();

Map<String, RawRequestable> DART_FILES = {
  "api": API(instanceManager),
  "selenium": SeleniumProxy(instanceManager)
};

Future<void> runServer(String basePath) async {
  final server = await HttpServer.bind('127.0.0.1', 6969);
  await for (HttpRequest request in server) {
    await handleRequest(basePath, request);
  }
}

Future<void> handleRequest(String basePath, HttpRequest request) async {
  String path = request.uri.path;
  String resultPath = path == '/' || path == '\\' ? '\\index.html' : path;
  File file = File('$basePath$resultPath');
  print(path);

  var subs = path.replaceAll('\\', '/').split('/').where((str) => str.trim().isNotEmpty).toList();
  var dartFile = getDartFile(subs);
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
  } else if (dartFile != null) {
    await dartFile.requestRaw(request, subs.skip(1).toList());
  } else {
    await sendNotFound(request.response);
  }
}

RawRequestable getDartFile(List<String> query) {
  return DART_FILES[query[0]];
}

Future<void> sendInternalError(HttpResponse response) async {
  response.statusCode = HttpStatus.internalServerError;
  await response.close();
}

Future<void> sendNotFound(HttpResponse response) async {
  response.statusCode = HttpStatus.notFound;
  await response.close();
}

void setResponseCode(HttpRequest request, int code, {String message = ''}) {
  request
    ..headers.contentType = ContentType('application', 'json')
    ..response.statusCode = code;
  if (message.trim().isNotEmpty) request.response.write(message);
  request.response.close();
}

Future<void> main(List<String> args) async => await runServer(args.isNotEmpty ? args[0] : File(Platform.script.toFilePath()).parent.path);
