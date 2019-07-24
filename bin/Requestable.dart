import 'dart:io';

abstract class Requestable {
  ContentType getContentType();
  String request(Map<String, String> queryParams);
}