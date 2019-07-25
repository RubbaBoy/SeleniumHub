import 'dart:html';

import 'package:SeleniumHub/src/inspector/inspector_component.dart';
import 'package:SeleniumHub/src/instances/instances_component.dart';
import 'package:SeleniumHub/src/route_paths.dart';
import 'package:SeleniumHub/src/settings/settings_component.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/app_layout/material_temporary_drawer.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_toggle/material_toggle.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

import 'src/routes.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: [
    'app_component.css',
    'package:angular_components/app_layout/layout.scss.css',
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
  ],
  templateUrl: 'app_component.html',
  directives: [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialPersistentDrawerDirective,
    MaterialTemporaryDrawerComponent,
    MaterialToggleComponent,
    InspectorComponent,
    InstancesComponent,
    SettingsComponent,
    routerDirectives,
    MaterialListComponent,
    MaterialListItemComponent,
  ],
  exports: [RoutePaths, Routes]
)
class AppComponent {

//  final Router _router;

//  AppComponent(this._router);

  void locationTo(String url) => window.location.assign(url);
  void routeTo(String route) => window.location.assign(route);
}
