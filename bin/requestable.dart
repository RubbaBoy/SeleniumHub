import 'dart:convert';
import 'dart:io';

abstract class RawRequestable {
  requestRaw(HttpRequest request, List<String> subs);
}

class Requestable extends RawRequestable {

  requestRaw(HttpRequest httpRequest, List<String> subs) async {
    var response = httpRequest.response
      ..headers.add('Access-Control-Allow-Origin', '*')
      ..statusCode = 200;
    var apiResponseAndMIME = await contentRequest(subs, httpRequest);
    response.headers.contentType = apiResponseAndMIME[1];
    dynamic sending = apiResponseAndMIME[0];
    if (sending is Map<String, dynamic>) sending = jsonEncode(sending);
    await response.write(sending);
    await response.close();
  }

  // Returns <dynamic Response, ContentType MIME>
  Future<dynamic> request(List<String> sub, Map<String, String> queryParams) async {}

  Future<List<dynamic>> contentRequest(List<String> sub, HttpRequest httpRequest) async {
    return [await request(sub, httpRequest.uri.queryParameters), getContentType()];
  }

  ContentType getContentType() {}
}
