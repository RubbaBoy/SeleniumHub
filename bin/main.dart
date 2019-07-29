import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:args/args.dart';
import 'package:mime/mime.dart';

import 'inspector/inspector_http_proxy.dart';
import 'instance_manager.dart';
import 'requestable.dart';
import 'api.dart';
import 'webdriver_controller.dart';
import 'selenium_proxy.dart';

int _port = 42069;
InstanceManager instanceManager = InstanceManager();
DriverController driverController = DriverController();

Map<String, RawRequestable> DART_FILES = {
  'api': API(instanceManager, driverController),
  'selenium': SeleniumProxy(instanceManager, driverController),
  'devtools': InspectorHttpProxy(instanceManager, driverController)
};

Future<void> runServer(String basePath) async {
  final server = await HttpServer.bind('0.0.0.0', _port);
  print('Webserver open on localhost:${_port}');
  await for (HttpRequest request in server) {
    await handleRequest(basePath, request);
  }
}

Future<void> handleRequest(String basePath, HttpRequest request) async {
  String path = request.uri.path;
  String resultPath = path == '/' || path == '\\' ? '${Platform.pathSeparator}index.html' : path;
  File file = File('$basePath$resultPath');

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
    } catch (e) {
      print('Error happened: $e');
      await sendInternalError(request.response);
    }
  } else if (dartFile != null) {
    try {
      await dartFile.requestRaw(request, subs.skip(1).toList());
    } catch (e) {
      print('Error happened: $e');
      await sendInternalError(request.response);
    }
  } else {
    await sendNotFound(request.response);
  }
}

RawRequestable getDartFile(List<String> query) {
  return query.isEmpty ? null : DART_FILES[query[0]];
}

Future<void> sendInternalError(HttpResponse response) async {
//  response.statusCode = HttpStatus.internalServerError;
  await response?.close();
}

Future<void> sendNotFound(HttpResponse response) async {
  response?.statusCode = HttpStatus.notFound;
  await response?.close();
}

void setResponseCode(HttpRequest request, int code, {String message = ''}) {
  request
    ..headers.contentType = ContentType.json
    ..response.statusCode = code;
  if (message.trim().isNotEmpty) request.response.write(message);
  request.response.close();
}

// main.dart [port] [build dir] [chromedriver path]
Future<void> main(List<String> args) async {
  if (args.isEmpty || args[0].toLowerCase() == 'help') {
    print('Usage: main.dart --port [port] --build [build dir] --driver [chromedriver path]');
    return;
  }

  var parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '42069')
    ..addOption('build', abbr: 'b', defaultsTo: '${File(Platform.script.toFilePath()).parent.parent.path}/build')
    ..addOption('driver', abbr: 'd', defaultsTo: '/usr/bin/chromedriver');

  var result = parser.parse(args);

  driverController.driverLocation = result['driver'];
  _port = int.parse(result['port']);

  if (await driverController.isDriverRunning()) {
    print('Grabbing initial instances...');
    await instanceManager.initCurrentInstances();
    print('Finished initializing initial instances');
  } else {
    print('Driver not running, so not checking for initial instances.');
  }

  await runServer(result['build']);
}
