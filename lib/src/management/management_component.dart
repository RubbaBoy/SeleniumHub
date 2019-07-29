//import 'dart:io';


import 'dart:async';

import 'package:SeleniumHub/src/inspector/inspector_component.dart';
import 'package:SeleniumHub/src/instances/instances_component.dart';
import 'package:SeleniumHub/src/settings/settings_component.dart';
import 'package:angular/security.dart';
import 'dart:convert';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

import '../routes.dart';

@Component(
  selector: 'management',
  styleUrls: [
    'management_component.css',
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'management_component.html',
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
class ManagementComponent implements OnInit, OnDestroy {

  final DomSanitizationService sanitizer;

  bool stop = false;
  bool showConfirmation;

  bool backendStatus = false;
  bool webserverStatus = false;
  bool webdriverStatus = false;

  ManagementComponent(this.sanitizer);

  @override
  void ngOnInit() {
    Timer.periodic(Duration(seconds: 1), (_t) {
      if (stop) {
        _t.cancel();
        return;
      }
      reloadStatuses();
    });
  }

  @override
  void ngOnDestroy() {
    stop = true;
  }

  void reloadStatuses() async {
    try {
      var apiStatus = await request('${Uri.base.origin}/api/youUp');
      backendStatus = apiStatus == 'yeah wyd';
    } catch (e) {}

    // Bruh you're on the webserver
    webserverStatus = true;

    try {
      var driverStatus = await request('${Uri.base.origin}/api/getDriverStatus');
      webdriverStatus = driverStatus == 'The driver is running';
    } catch (e) {}
  }

  void confirmStop() async {
    showConfirmation = false;
    await HttpRequest.getString('${Uri.base.origin}/api/stopDriver');
    print('Stopped webdriver.');
  }

  Future<void> startDriver() async {
    await request('${Uri.base.origin}/api/startDriver');
    reloadStatuses();
  }

  Future<String> request(String url) async {
    try {
      return jsonDecode(await HttpRequest.getString(url))['message'];
    } catch (e) {}
    return '';
  }

}
