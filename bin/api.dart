import 'dart:convert';
import 'dart:io';

import 'package:SeleniumHub/src/settings.dart';
import 'package:SeleniumHub/selenium_instance.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'instance_manager.dart';
import 'requestable.dart';
import 'webdriver_controller.dart';

class API extends Requestable {

  var client = http.Client();
  InstanceManager instanceManager;
  DriverController driverController;

  API(this.instanceManager, this.driverController);

  @override
  Future<dynamic> request(List<String> sub, Map<String, String> queryParams) async {
    if (!driverController.DRIVER_STARTED && !['youUp', 'getDriverStatus', 'startDriver', 'stopDriver'].contains(sub[0])) return { 'message': 'The web driver has not yet been started.' };
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
      case 'getSettings':
        String settingsFile = '';
        try {
          settingsFile = await File('settings.json').readAsString();
        } catch (e) {
          print(e);
        }
        return Settings.fromJson(jsonDecode(settingsFile)).toJson();
      case 'setSettings':
        // This is for lazy setting validation
        var value = queryParams['value'];
        if (value == null) return {'message': 'Required query parameter: value'};
        var settings = Settings.fromJson(jsonDecode(value));
        try {
          await File('settings.json').writeAsString(
              jsonEncode(settings.toJson()));
          print('Writing: ${jsonEncode(settings.toJson())}');
        } catch (e) {
          return {'message': 'An error occured. Here are the details: $e'};
        }
        return {'message': 'Successfully wrote to settings'};
      case 'getDriverStatus':
        return { 'message': 'The driver is ${await driverController.isDriverRunning() ? '' : 'not '}running' };
      case 'startDriver':
        if (await driverController.isDriverRunning()) return { 'message': 'The driver has already been started' };
        await driverController.startDriver();
        return { 'message': 'The driver has been started' };
      case 'stopDriver':
        if (!await driverController.isDriverRunning()) return { 'message': 'The driver has already been stopped' };
        await driverController.stopDriver();
        return { 'message': 'The driver has been stopped' };
      case 'youUp':
        return {'message': 'yeah wyd'};
      default:
        return {'message': 'Unknown endpoint "${sub[0]}"'};
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