//import 'dart:io';


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

  Future getData() async {
    var path = '//localhost:6969/api/getInstances?limit=3&skip=1';
    try {
      return await HttpRequest.getString(path);
    } catch (e) {
      print('Couldn\'t open $path');
    }
  }

  @override
  void ngOnInit() {
    getData().then((res) {
      print('Res = $res');
    });

//    HttpClient().getUrl(Uri.parse('//localhost:6969/api/getInstances?limit=3&skip=1')).then((request) {
//      // sends the request
////      request.close().then((response) {
////        // transforms and prints the response
////        response.transform(Utf8Decoder()).forEach((contents) {
////          print(contents);
////        });
////      });
//    });
  }

//  void add() {
//    SeleniumInstance.add(newTodo);
//    newTodo = '';
//  }
}
