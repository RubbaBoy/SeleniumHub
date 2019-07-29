
import 'dart:async';

import 'package:SeleniumHub/src/inspector/inspector_component.dart';
import 'package:SeleniumHub/src/instances/instances_component.dart';
import 'package:angular/security.dart';
import 'dart:convert';
import 'dart:html';

import 'package:SeleniumHub/selenium_instance.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:recase/recase.dart';
import 'package:clippy/browser.dart' as clippy;

import '../routes.dart';
import '../settings.dart';

@Component(
  selector: 'settings',
  styleUrls: [
    'settings_component.css',
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'settings_component.html',
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
    materialNumberInputDirectives,
    MaterialToggleComponent
  ],
  providers: [overlayBindings],
  exports: [RoutePaths, Routes]
)
class SettingsComponent implements OnInit {

  final DomSanitizationService sanitizer;
  Settings settings;
  String saveStatus;
  bool showStatus;
  bool isError;

  set updateScreenshots(bool update) => settings.updateScreenshots = update;
  get updateScreenshots => settings?.updateScreenshots ?? true;

  set screenshotInterval(int value) => settings.screenshotInterval = value;
  get screenshotInterval => settings?.screenshotInterval ?? 2000;

  SettingsComponent(this.sanitizer);

  @override
  void ngOnInit() {
    initSettings();
  }

  void initSettings() async {
    var json = await HttpRequest.getString('//localhost:42069/api/getSettings');
    settings = Settings.fromJson(jsonDecode(json));
    updateScreenshots = settings.updateScreenshots;
    screenshotInterval = settings.screenshotInterval;
  }

  void saveConfig() {
    print('Saving config ${jsonEncode(settings.toJson())}');
    HttpRequest.getString('//localhost:42069/api/setSettings?value=${jsonEncode(settings.toJson())}').then((result) {
      var message = jsonDecode(result)['message'];
      isError = message != 'Successfully wrote to settings';
      saveStatus = message;
      showStatus = true;

      Timer(Duration(seconds: 2), () => showStatus = false);
    });
  }

}
