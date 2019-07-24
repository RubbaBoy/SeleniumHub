import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'todo-list',
  styleUrls: ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: [
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

  @override
  Future<Null> ngOnInit() async {
    var request = await HttpClient().getUrl(Uri.parse('//localhost:6969/api/getInstances?limit=3&skip=1'));
    // sends the request
    var response = await request.close();

    // transforms and prints the response
    await for (var contents in response.transform(Utf8Decoder())) {
      print(contents);
    }
  }

//  void add() {
//    SeleniumInstance.add(newTodo);
//    newTodo = '';
//  }
}
