import 'dart:convert';
import 'dart:io';
import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:http/http.dart' as http;

import 'instance_manager.dart';
import 'main.dart';
import 'requestable.dart';

class SeleniumProxy extends RawRequestable {
  InstanceManager instanceManager;

  SeleniumProxy(this.instanceManager);

  @override
  requestRaw(HttpRequest request, List<String> subs) async {
    var body = await getBody(request);

    var seleniumUrl = request.uri.toString().replaceFirst('/selenium/', '');
    var contentType = [];
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
    contentType = rawContentType?.split('/');

    print(jsonBody);

    var proxyResponse = request.response
      ..headers.contentType = ContentType(contentType[0], contentType[1])
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
          true,
          value['browserName'],
          value['chrome']['chromedriverVersion'],
          value['chrome']['userDataDir'],
          value['goog:chromeOptions']['debuggerAddress'],
          value['platform'],
          value['version']));
    }

    return;
  }

  Future<String> getBody(HttpRequest request) async {
    var content = "";
    await for (var contents in request.transform(Utf8Decoder())) {
      content += contents;
    }
    return content;
  }
}
