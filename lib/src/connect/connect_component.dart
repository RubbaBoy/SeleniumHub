//import 'dart:io';


import 'dart:async';

import 'package:SeleniumHub/src/inspector/inspector_component.dart';
import 'package:SeleniumHub/src/instances/instances_component.dart';
import 'package:SeleniumHub/src/settings/settings_component.dart';
import 'package:angular/security.dart';
import 'dart:convert';
import 'dart:html';

import 'package:SeleniumHub/src/instances/selenium_instance.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:recase/recase.dart';
import 'package:clippy/browser.dart' as clippy;

import '../routes.dart';

@Component(
  selector: 'connect',
  styleUrls: [
    'connect_component.css',
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'connect_component.html',
  directives: [
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    AutoDismissDirective,
    AutoFocusDirective,
    MaterialIconComponent,
    MaterialButtonComponent,
    MaterialTooltipDirective,
    MaterialDialogComponent,
    ModalComponent,
    ModalComponent,
    NgFor,
    NgIf,
    routerDirectives,
    InspectorComponent,
    InstancesComponent,
    SettingsComponent,
  ],
  providers: [overlayBindings],
  exports: [RoutePaths, Routes]
)
class ConnectComponent implements OnInit {

  final DomSanitizationService sanitizer;

  String host;
  int port;

  ConnectComponent(this.sanitizer);

  @override
  void ngOnInit() {
    host = Uri.base.host;
    port = Uri.base.port;
  }

  void copy(String copy) => clippy.write(copy);

}
