import 'dart:async';
import 'dart:convert';

import 'package:SeleniumHub/src/instances/selenium_instance.dart';
import 'package:http/http.dart' as http;

class InstanceManager {
  var client = http.Client();
  List<SeleniumInstance> instances = [];
  List<InstanceWatcher> watchers = [];

  void addInstance(SeleniumInstance instance) {
    instances.add(instance);
    addWatcher(instance);
  }

  void addWatcher(SeleniumInstance instance) =>
      watchers.add(InstanceWatcher(instance)..start(this, () => deleteInstance(instance.sessionId)));

  void removeWatcher(SeleniumInstance instance) {
    watchers.where((watcher) => watcher.instance == instance).toList().forEach((watcher) {
      watcher.stop();
      watchers.remove(watcher);
    });
  }

  void deleteInstance(String id) {
    client.delete('http://localhost:4444/session/$id');
    var instance = instances.firstWhere((instance) => instance.sessionId == id, orElse: () => null);
    if (instance != null) {
      removeWatcher(instance);
      instances.remove(instance);
    }
  }

  Future<String> getScreenshot(String id) async => jsonDecode((await client.get('http://localhost:4444/session/$id/screenshot')).body)['value'];

  // Other data *may* be mutable, but this is the data very often changed
  void updateMutableData(SeleniumInstance instance, String base64, String url) {
    if (instance.screenshot != base64 || instance.url != url) {
      instance.screenshot = base64;
      instance.url = url;
      instance.refreshRevision();
    }
  }

  Future<String> getUrl(String id) => client
        .get('http://localhost:4444/session/$id/url')
        .then((response) => jsonDecode(response.body)['value']);

  int getPort(SeleniumInstance instance) => int.parse(instance.debuggerAddress.split(':')[1]);

  SeleniumInstance getInstance(String id) => instances.firstWhere((instance) => instance.sessionId == id);

  Future<void> initCurrentInstances() async {
    var response = await client.get('http://localhost:4444/sessions');
    var values = jsonDecode(response.body)['value'];
    for (var value in values) {
      Map<String, dynamic> current = value['capabilities'];
      var id = value['id'];
      if (!(await InstanceWatcher.canConnect(id))) {
        print('Can\'t initially connect to $id');
        deleteInstance(id);
        continue;
      }

      print('Added $id');
      var instance = SeleniumInstance(
          id,
          '0.0.0.0',
          current['browserName'],
          current['chrome']['chromedriverVersion'],
          current['chrome']['userDataDir'],
          current['goog:chromeOptions']['debuggerAddress'],
          current['platform'],
          current['version'],
          await getScreenshot(id),
          await getUrl(id));
      addInstance(instance);
    }
  }
}

class InstanceWatcher {
  static var client = http.Client();
  SeleniumInstance instance;
  Timer timer;

  InstanceWatcher(this.instance);

  void start(InstanceManager instanceManager, void ifUnreachable()) {
    timer = Timer.periodic(Duration(seconds: 2), (_t) async {
      bool connectable = await canConnect(instance.sessionId);
      if (!connectable) {
        _t.cancel();
        ifUnreachable();
      } else {
        instanceManager.updateMutableData(instance, await instanceManager.getScreenshot(instance.sessionId), await instanceManager.getUrl(instance.sessionId));
      }
    });
  }

  void stop() => timer.cancel();

  static Future<bool> canConnect(String id) => client
        .get('http://localhost:4444/session/$id/url')
        .then((response) => jsonDecode(response.body)['status'] == 0);
}
