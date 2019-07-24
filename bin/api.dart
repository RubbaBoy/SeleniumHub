import 'dart:convert';
import 'dart:io';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:uuid/uuid.dart';

import 'requestable.dart';

class API extends Requestable {

  List<SeleniumInstance> _instances = [];
  Uuid uuid = Uuid();

  @override
  dynamic request(List<String> sub, Map<String, String> queryParams) {
    switch (sub[0]) {
      case 'getInstances':
        return jsonEncode(_instances.map((instance) => instance.toJson()));
      case 'addInstance':
        var thisUuid = uuid.v5(Uuid.NAMESPACE_URL, 'uddernetworks.com');
        var verify = verifyParameters(queryParams, ['ip']);
        return {
          'message': 'Added instance',
          'id': thisUuid
        };
      case 'removeInstance':

        return null;
      default:
        return {'message': 'unknown endpoint "${sub[0]}"'};
    }
  }

  String json(Map<String, dynamic> json) {
    return jsonEncode(json);
  }

  Map<String, dynamic> verifyParameters(Map<String, String> queryParams, List<String> verify) {
    if (queryParams.keys.toSet().containsAll(verify)) return { 'message': 'Error: required parameters: ${verify.join(', ')}' };
    return null;
  }

  @override
  ContentType getContentType() => ContentType('application', 'json');
}