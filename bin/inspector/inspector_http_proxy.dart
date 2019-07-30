import 'dart:io';

import '../instance_manager.dart';
import '../requestable.dart';
import 'package:http/http.dart' as http;

import '../webdriver_controller.dart';

class InspectorHttpProxy extends Requestable {

  var client = http.Client();
  InstanceManager instanceManager;
  DriverController driverController;

  InspectorHttpProxy(this.instanceManager, this.driverController);

  @override
  Future<List<dynamic>> contentRequest(List<String> sub, HttpRequest request) async {
    if (!driverController.DRIVER_STARTED) {
      print('Webdriver not started');
      request.response.statusCode = HttpStatus.internalServerError;
      return [{ 'message': 'The web driver has not yet been started.' }, ContentType.json];
    }

    if (sub.isEmpty || sub[0].length != 32) return [{ 'message': 'URL format must follow: /devtools/:sessionId/' }, ContentType.json];
    var instance = instanceManager.getInstance(sub[0]);
    if (instance == null) return [{ 'message': 'Unknown sessionId: ${sub[0]}' }, ContentType.json];
    int port = instanceManager.getPort(instance);

    var proxyUrl = 'http://localhost:$port${request.uri.toString().replaceFirst('/devtools/${sub[0]}', '/devtools')}';

    var response = await client.get(proxyUrl);
    var rawContentType = response.headers['content-type'] ?? 'text/plain';

    request.response.headers.set('X-Frame-Options', 'allow-from: *');
    return [response.body, ContentType.parse(rawContentType)];
  }

}