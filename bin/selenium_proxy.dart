import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:SeleniumHub/src/instances/selenium_instance.dart';
import 'package:http/http.dart' as http;

import 'instance_manager.dart';
import 'main.dart';
import 'requestable.dart';

class SeleniumProxy extends RawRequestable {
  InstanceManager instanceManager;

  SeleniumProxy(this.instanceManager);

  @override
  requestRaw(HttpRequest request, List<String> subs) async {
    var body = UIntStuffToString(request);

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
      var value = json['value'];
      print('Created instance with session ID of ${json['sessionId']}');

      // TODO: Assuming chrome for now
      instanceManager.addInstance(SeleniumInstance(
          json['sessionId'],
          request.connectionInfo.remoteAddress.address,
          value['browserName'],
          value['chrome']['chromedriverVersion'],
          value['chrome']['userDataDir'],
          value['goog:chromeOptions']['debuggerAddress'],
          value['platform'],
          value['version'],
          await instanceManager.getScreenshot(json['sessionId']),
          await instanceManager.getUrl(json['sessionId'])));
    }
  }

  static String UIntStuffToString(HttpRequest request) {
    StringBuffer buffer = StringBuffer();
    request.forEach((bytes) {
      for (int i = 0; i < bytes.length;) {
        int firstWord = (bytes[i] << 8) + bytes[i + 1];
        if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
          int secondWord = (bytes[i + 2] << 8) + bytes[i + 3];
          buffer.writeCharCode(
              ((firstWord - 0xD800) << 10) + (secondWord - 0xDC00) + 0x10000);
          i += 4;
        }
        else {
          buffer.writeCharCode(firstWord);
          i += 2;
        }
      }
    });
    return buffer.toString();
  }

}
