//import 'dart:io';


import 'dart:convert';
import 'dart:html';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'todo-list',
  styleUrls: [
    'todo_list_component.css',
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'todo_list_component.html',
  directives: [
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    NgFor,
    NgIf,
  ],
)
class TodoListComponent implements OnInit {

  List<SeleniumInstance> instances = [];

  Future<String> getData() async {
    var path = '//localhost:6969/api/getInstances';
    try {
      return await HttpRequest.getString(path);
    } catch (e) {
      print('Couldn\'t open $path');
      return '[]';
    }
  }

  @override
  void ngOnInit() {
    getData().then((res) {
      jsonDecode(res).forEach((instanceJson) {
        print('Creating instance from \n$instanceJson');
        instances.add(SeleniumInstance.fromJson(instanceJson));
      });
    });
  }
}
