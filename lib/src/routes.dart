import 'package:angular_router/angular_router.dart';

import 'instances/instances_component.template.dart' as instances_template;
import 'inspector/inspector_component.template.dart' as inspector_template;
import 'settings/settings_component.template.dart' as settings_template;
import 'connect/connect_component.template.dart' as connect_template;
import 'management/management_component.template.dart' as management_template;
import 'route_paths.dart';

export 'route_paths.dart';

class Routes {
  static final instances = RouteDefinition(
    routePath: RoutePaths.instances,
    component: instances_template.InstancesComponentNgFactory,
    useAsDefault: true
  );

  static final inspector = RouteDefinition(
    routePath: RoutePaths.inspector,
    component: inspector_template.InspectorComponentNgFactory,
  );

  static final settings = RouteDefinition(
    routePath: RoutePaths.settings,
    component: settings_template.SettingsComponentNgFactory,
  );

  static final connect = RouteDefinition(
    routePath: RoutePaths.connect,
    component: connect_template.ConnectComponentNgFactory,
  );

  static final management = RouteDefinition(
    routePath: RoutePaths.management,
    component: management_template.ManagementComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    instances,
    inspector,
    settings,
    connect,
    management,
  ];
}