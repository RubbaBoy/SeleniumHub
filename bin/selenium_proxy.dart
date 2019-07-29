import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:SeleniumHub/selenium_instance.dart';
import 'package:http/http.dart' as http;

import 'instance_manager.dart';
import 'main.dart';
import 'requestable.dart';
import 'webdriver_controller.dart';

class SeleniumProxy extends RawRequestable {
  InstanceManager instanceManager;
  DriverController driverController;

  SeleniumProxy(this.instanceManager, this.driverController);

  @override
  requestRaw(HttpRequest request, List<String> subs) async {
    if (!await driverController.isDriverRunning()) {
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
      return;
    }

    var body = await UIntStuffToString(request);

    var seleniumUrl = request.uri.toString().replaceFirst('/selenium/', '');
    var client = http.Client();
    http.Response response;
    var method = request.method.toLowerCase();
    response = method == 'post'
        ? await client.post('http://127.0.0.1:4444/$seleniumUrl',
            headers: {'content-type': 'application/json'}, body: body)
        : (method == 'delete'
        ? await client.delete('http://127.0.0.1:4444/$seleniumUrl',
            headers: {'content-type': 'application/json'})
        : await client.get('http://127.0.0.1:4444/$seleniumUrl',
            headers: {'content-type': 'application/json'}));

    var rawContentType = response.headers['content-type'] ?? 'text/plain';
    var jsonBody = response.body;

    var proxyResponse = request.response
      ..headers.contentType = ContentType.parse(rawContentType)
      ..statusCode = response.statusCode;
    await proxyResponse.write(jsonBody);
    await proxyResponse.close();

    ////////////// Hooks

    if (seleniumUrl == 'session') {
      var json = jsonDecode(jsonBody);
      print(json);
      var value = json['value'];
      var sessionId = json['sessionId'] ?? value['sessionId'];
      if (sessionId == null) {
        print('Attempted to create selenium with no ID');
        return;
      }
      print('Created instance with session ID of $sessionId');

      // TODO: Assuming chrome for now
      instanceManager.addInstance(SeleniumInstance(
          sessionId,
          request.connectionInfo.remoteAddress.address,
          value['browserName'],
          value['chrome']['chromedriverVersion'],
          value['chrome']['userDataDir'],
          value['goog:chromeOptions']['debuggerAddress'],
          value['platform'],
          value['version'],
          await instanceManager.getScreenshot(sessionId),
          await instanceManager.getUrl(sessionId)));
    }
  }

  static Future<String> UIntStuffToString(HttpRequest request) {
    return request.map((bytes) => bytes.map((value) => String.fromCharCode(value)).join('')).join('');
  }

}
