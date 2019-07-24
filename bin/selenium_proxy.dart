import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'requestable.dart';

class SeleniumProxy extends RawRequestable {

  @override
  requestRaw(HttpRequest request, List<String> subs) async {
//    if (subs.isEmpty || subs[0] != 'hub') {
//      setResponseCode(request, 404);
//      return;
//    }

  print('\n\n\n======================================================================== Dart received ========================================================================');
  print('');

    print('================== Selenium proxy ==================');
    print('Sub = $subs');
    print(request);
    print(request.uri);
    print(request.requestedUri.toString());
    print(request.uri.queryParameters);

    var body = await getBody(request);
    body = body.replaceAll('\n\r', '\n');
    print('Body = $body');
    print('Body type: ${body.runtimeType}');

//    await request.response.close();

    print('USING URI: ' + 'http://127.0.0.1:4444/${subs.join('/')}');


    var contentType = [];
    int statusCode = 200;
    String respBody = '';

    var client = http.Client();
    if (request.method.toLowerCase() == 'post') {
      var seleniumResponse = await client.post(
          'http://127.0.0.1:4444/${subs.join('/')}',
          headers: {'content-type': 'application/json'},
          body: body
      );

      print('================== RESPONSE ==================');
      print('Headers: ${seleniumResponse.headers}');
      print('Body: ${seleniumResponse.body}');

      contentType = seleniumResponse.headers['content-type']?.split('/');
      statusCode = seleniumResponse.statusCode;
      respBody = seleniumResponse.body;
    } else {
      print('Sending exact ${'http://127.0.0.1:4444${request.uri.toString().replaceFirst('/selenium', '')}'}');
      var seleniumResponse = await client.get(
          'http://127.0.0.1:4444${request.uri.toString().replaceFirst('/selenium', '')}',
          headers: {'content-type': 'application/json'}
      );

      contentType = seleniumResponse.headers['content-type']?.split('/');
      statusCode = seleniumResponse.statusCode;
      respBody = seleniumResponse.body;
    }

    var proxyResponse = request.response
      ..headers.contentType = ContentType(contentType[0], contentType[1])
      ..statusCode = statusCode;
    await proxyResponse.write(respBody);
    await proxyResponse.close();


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