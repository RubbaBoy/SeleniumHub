import 'dart:convert';
import 'dart:io';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'instance_manager.dart';
import 'requestable.dart';

class API extends Requestable {

  var client = http.Client();
  InstanceManager instanceManager;

  API(this.instanceManager);

  @override
  Future<dynamic> request(List<String> sub, Map<String, String> queryParams) async {
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
          'screenshot': instance.screenshot,
          'url': instance.url
        }).toList());
        break;
      case 'stopInstances':
        var ids = queryParams['sessionIds'];
        if (ids == null) return {'message': 'Required query parameter: sessionIds'};
        var sessionIds = ids.split(',');
        sessionIds.forEach((id) async {
          await client.delete('http://localhost:4444/session/$id');
          instanceManager.deleteInstance(id);
        });
        break;
      case 'devToolsList':
        var id = queryParams['sessionId'];
        if (id == null) return {'message': 'Required query parameter: sessionId'};
        var instance = instanceManager.getInstance(id);
        if (instance == null) return {'message': 'Unknown sessionId: $id'};
        return (await client.get('http://${instance.debuggerAddress}/json/list')).body;
      default:
        return {'message': 'unknown endpoint "${sub[0]}"'};
    }
  }

  String json(Map<String, dynamic> json) {
    return jsonEncode(json);
  }

  Map<String, dynamic> verifyParameters(Map<String, String> queryParams, List<String> verify) {
    if (queryParams.keys.toSet().containsAll(verify)) return { 'message': 'Required parameters: ${verify.join(', ')}' };
    return null;
  }

  @override
  ContentType getContentType() => ContentType.json;
}