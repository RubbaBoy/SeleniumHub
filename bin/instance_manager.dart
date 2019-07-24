import 'dart:async';
import 'dart:convert';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:http/http.dart' as http;

class InstanceManager {

  var client = http.Client();
  List<SeleniumInstance> instances = [];
  List<InstanceWatcher> watchers = [];

  void addInstance(SeleniumInstance instance) => instances.add(instance);

  void removeInstance(SeleniumInstance instance) => instances.remove(instance);

  void addWatcher(String id) => watchers.add(InstanceWatcher(id)..start(() => deleteInstance(id)));

  void deleteInstance(String id) => client.delete('http://localhost:4444/session/$id');

  Future<void> initCurrentInstances() async {
    var response = await client.get('http://localhost:4444/sessions');
    var values = jsonDecode(response.body)['value'];
    print(values);
    for (var value in values) {
      Map<String, dynamic> current = value['capabilities'];
      var id = value['id'];
      if (!(await InstanceWatcher.canConnect(id))) {
        print('Can\'t initially connect to $id');
        deleteInstance(id);
        continue;
      }

      print('Added $id');
      addInstance(SeleniumInstance(
          id,
          'unknown',
          true,
         current['browserName'],
         current['chrome']['chromedriverVersion'],
         current['chrome']['userDataDir'],
         current['goog:chromeOptions']['debuggerAddress'],
         current['platform'],
         current['version']));
    }
  }
}

class InstanceWatcher {

  static var client = http.Client();
  String id;
  Timer timer;

  InstanceWatcher(this.id);

  void start(void ifUnreachable()) {
    timer = Timer.periodic(Duration(seconds: 2), (_t) async {
      bool connectable = await canConnect(id);
      if (!connectable) {
        _t.cancel();
        ifUnreachable();
      }
    });
  }

  static Future<bool> canConnect(String id) => client.get('http://localhost:4444/session/$id/url').then((response) => jsonDecode(response.body)['status'] != 100);
}
