import 'dart:io';

import 'Requestable.dart';

class API implements Requestable {

  @override
  String request(Map<String, String> queryParams) {
    return r'{"message": "This is a test with some JSON shit"}';
  }

  @override
  ContentType getContentType() => ContentType('application', 'json');
}