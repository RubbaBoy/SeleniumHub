import 'package:angular_router/angular_router.dart';

import 'todo_list/instances_component.template.dart' as instances_template;
import 'inspector/inspector_component.template.dart' as inspector_template;
import 'route_paths.dart';

export 'route_paths.dart';

class Routes {
  static final instances = RouteDefinition(
    routePath: RoutePaths.instances,
    component: instances_template.TodoListComponentNgFactory,
    useAsDefault: true
  );

  static final inspector = RouteDefinition(
    routePath: RoutePaths.inspector,
    component: inspector_template.TodoListComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    instances,
    inspector,
  ];
}