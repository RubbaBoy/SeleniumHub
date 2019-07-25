import 'dart:convert';
import 'dart:io';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:uuid/uuid.dart';

import 'instance_manager.dart';
import 'requestable.dart';

class API extends Requestable {

  InstanceManager instanceManager;

  API(this.instanceManager);

  @override
  dynamic request(List<String> sub, Map<String, String> queryParams) {
    switch (sub[0]) {
      case 'getInstances':
        var sessionIds = queryParams['sessionIds']?.split(',') ??
            instanceManager.instances.map((instance) => instance.sessionId);
        return jsonEncode(instanceManager.instances
            .where((instance) => sessionIds.contains(instance.sessionId))
            .map((instance) => instance.toJson()).toList());
      case 'getRevisions':
        return jsonEncode(instanceManager.instances.map((instance) => {
          'sessionId': instance.sessionId,
          'revisionId': instance.revisionId
        }).toList());
      case 'getRevised': // TODO: Do more than give the screenshots?
        var ids = queryParams['sessionIds'];
        if (ids == null) return {'message': 'Required query parameter: sessionIds'};
        var sessionIds = ids.split(',');
        return jsonEncode(instanceManager.instances
            .where((instance) => sessionIds.contains(instance.sessionId))
            .map((instance) => {
          'sessionId': instance.sessionId,
          'revisionId': instance.revisionId,
          'screenshot': instance.screenshot
        }).toList());
        break;
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