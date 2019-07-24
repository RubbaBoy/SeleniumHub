import 'dart:convert';
import 'dart:io';

abstract class RawRequestable {
  requestRaw(HttpRequest request, List<String> subs);
}

class Requestable extends RawRequestable {

  requestRaw(HttpRequest httpRequest, List<String> subs) async {
    var response = httpRequest.response
      ..headers.contentType = getContentType()
      ..statusCode = 200;
    var apiResponse = request(subs, httpRequest.uri.queryParameters);
    var sending = apiResponse;
    if (apiResponse is Map<String, dynamic>) sending = jsonEncode(apiResponse);
    await response.write(sending);
    await response.close();
  }

  dynamic request(List<String> sub, Map<String, String> queryParams) {}
  ContentType getContentType() {}
}