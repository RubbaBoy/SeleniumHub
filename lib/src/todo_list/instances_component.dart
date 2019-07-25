//import 'dart:io';


import 'dart:async';

import 'package:angular/security.dart';
import 'dart:convert';
import 'dart:html';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:recase/recase.dart';
import 'package:clippy/browser.dart' as clippy;

import '../routes.dart';

@Component(
  selector: 'instances',
  styleUrls: [
    'instances_component.css',
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'instances_component.html',
  directives: [
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialCheckboxComponent,
    MaterialFabComponent,
    materialInputDirectives,
    AutoDismissDirective,
    AutoFocusDirective,
    MaterialTooltipDirective,
    MaterialDialogComponent,
    ModalComponent,
    MaterialExpansionPanel,
    MaterialExpansionPanelAutoDismiss,
    MaterialExpansionPanelSet,
    MaterialYesNoButtonsComponent,
    NgFor,
    NgIf,
    NgModel,
    routerDirectives,
    FocusListDirective,
    MaterialInputComponent,
  ],
  providers: [overlayBindings],
  exports: [RoutePaths, Routes]
)
class TodoListComponent implements OnInit {

  SeleniumInstance showingInfo;
  bool showInfo = false;
  bool showConfirmation = false;
  bool showInspectChooser = false;
  String confirmingId;
  Set<SeleniumInstance> instances = Set();
  SeleniumInstance inspectingInstance;
  List<Map<String, dynamic>> inspectWindows = [];
//  Map<String, String> currRevisions = {};

  final Router _router;
  final DomSanitizationService sanitizer;

  TodoListComponent(this.sanitizer, this._router);

  Future<String> getData() async {
    var path = '//localhost:6969/api/getInstances';
    try {
      return await HttpRequest.getString(path);
    } catch (e) {
      print('Couldn\'t open $path');
      return '[]';
    }
  }

  Future<Map<String, String>> getRevisions() async {
    try {
      var json = await HttpRequest.getString('//localhost:6969/api/getRevisions');
      Map<String, String> result = {};
      jsonDecode(json).forEach((json) => result[json['sessionId']] = json['revisionId']);
      return result;
    } catch (e) {
      print('Couldn\'t open');
      return {};
    }
  }

  @override
  void ngOnInit() {
    checkRevisions();
  }

  void checkRevisions() async {
    try {
      var revisions = await getRevisions();

      // If current has revisions the server doesn't have, remove it
      instances.removeWhere((instance) =>
      !revisions.containsKey(instance.sessionId));

      // If the current revisions are different than the existing ones, add them to a list to update their screenshot
      var updateScreenshotIds = instances.where((instance) =>
      instance.revisionId != revisions[instance.sessionId]).toList();

      // If the server's revisions have IDs the current list doesn't have, add them to a list to be added
      var _tempIds = instances.map((instance) => instance.sessionId);
      var newIds = List.from(revisions.keys)
        ..removeWhere((id) => _tempIds.contains(id));
//      print('Revision ids: ${revisions.keys}\tTemp ids: $_tempIds\tFinal: $newIds');

      if (updateScreenshotIds.isNotEmpty) {
        var revisedParam = updateScreenshotIds.map((instance) =>
        instance.sessionId).join(',');
        var json = jsonDecode(await HttpRequest.getString(
            '//localhost:6969/api/getRevised?sessionIds=$revisedParam'));
        json.forEach((json) => getInst(json['sessionId'])
            ..revisionId = json['revisionId']
            ..screenshot = json['screenshot']
            ..url = json['url']);
      }

      if (newIds.isNotEmpty) {
        var revisedParam = newIds.join(',');
        var json = jsonDecode(await HttpRequest.getString(
            '//localhost:6969/api/getInstances?sessionIds=$revisedParam'));
        json.forEach((json) {
          instances.add(SeleniumInstance.fromJson(json));
          print('New instance ${json['sessionId']}');
        });
      }
    } catch (e) {
      print(e);
    }

    Timer(Duration(seconds: 2), () => checkRevisions());
  }

  void showStopConfirmation(SeleniumInstance instance) {
    confirmingId = instance.sessionId;
    showConfirmation = true;
  }

  void cancelStopConfirm() {
    confirmingId = null;
    showConfirmation = false;
  }

  void confirmStop() {
    if (confirmingId == null) return;
    showConfirmation = false;
    print('User confirmed to stop $confirmingId');
    HttpRequest.getString(
        '//localhost:6969/api/stopInstances?sessionIds=$confirmingId');
  }

  void showInfoModal(SeleniumInstance instance) {
    showInfo = true;
    showingInfo = instance;
    jsonEncode(instance.toJson());
  }

  String displayJson(SeleniumInstance instance) {
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(showingInfo?.toJson() ?? {});
  }

  String getIcon(String platform) {
    platform = platform.toLowerCase();
    if (platform.contains('windows')) return 'windows-icon';
    if (platform.contains('mac') || platform.contains('osx')) return 'mac-icon';
    return 'linux-icon';
  }

  void openInspectChooser(SeleniumInstance instance) {
    HttpRequest.getString(
        '//localhost:6969/api/devToolsList?sessionId=${instance.sessionId}').then((response) {
          print('Response: $response');
          inspectWindows.clear();
          inspectingInstance = instance;
          jsonDecode(response).forEach((dyn) => inspectWindows.add(dyn as Map<String, dynamic>));
          print(inspectWindows);
          showInspectChooser = true;
    });
  }

  void inspectWindow(Map<String, dynamic> inspect) {
    showInspectChooser = false;
    print('Inspecting ${inspect['title']}');

    var inspector = '/#${RoutePaths.inspector.toUrl()}?sessionId=${inspectingInstance.sessionId}&page=${inspect['id']}';
    print('Inspecting to: $inspector');
    window.location.assign(inspector);
  }

  SeleniumInstance getInst(String id) => instances.firstWhere((instance) => instance.sessionId == id);

  String camelCase(String input) => ReCase(input).titleCase;

  dynamic getBackgroundFor(String screenshot) => sanitizer.bypassSecurityTrustStyle('background-image: url(data:image/png;base64,$screenshot)');

  dynamic getURL(String url) => sanitizer.bypassSecurityTrustUrl(url);

  void copy(String copy) => clippy.write(copy);

}