import 'dart:io';

import '../instance_manager.dart';
import '../requestable.dart';
import 'package:http/http.dart' as http;

class InspectorHttpProxy extends Requestable {

  var client = http.Client();
  InstanceManager instanceManager;

  InspectorHttpProxy(this.instanceManager);

  @override
  Future<List<dynamic>> contentRequest(List<String> sub, HttpRequest request) async {
    if (sub.isEmpty || sub[0].length != 32) return [{'message': 'URL format must follow: /devtools/:sessionId/'}, ContentType.json];
    var instance = instanceManager.getInstance(sub[0]);
    if (instance == null) return [{'message': 'Unknown sessionId: ${sub[0]}'}, ContentType.json];
    int port = instanceManager.getPort(instance);
    print('Using port: $port');

    var proxyUrl = 'http://localhost:$port${request.uri.toString().replaceFirst('/devtools/${sub[0]}', '/devtools')}';
    print('Requesting path: $proxyUrl');

    var response = await client.get(proxyUrl);
    var rawContentType = response.headers['content-type'] ?? 'text/plain';

    request.response.headers.set('X-Frame-Options', 'allow-from: localhost');
    return [response.body, ContentType.parse(rawContentType)];
  }

}