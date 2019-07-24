import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';

class InstanceManager {
  List<SeleniumInstance> instances = [];

  void addInstance(SeleniumInstance instance) {
    instances.add(instance);
    // TODO: Notify web clients
  }

  void removeInstance(SeleniumInstance instance) {
    instances.remove(instance);
    // TODO: Notify web clients
  }
}
