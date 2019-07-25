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
  selector: 'inspector',
  styleUrls: [
    'inspector_component.css',
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'inspector_component.html',
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
    routerDirectives
  ],
  providers: [overlayBindings],
  exports: [RoutePaths, Routes]
)
class TodoListComponent implements OnInit {

  DomSanitizationService sanitizer;
  bool invalidParams = false;
  SafeValue safeIFrame;

  set iFrameLink(String url) => safeIFrame = sanitizer.bypassSecurityTrustResourceUrl(url);

  TodoListComponent(this.sanitizer);

  @override
  void ngOnInit() {
    print('Split: ${Uri.base.toString().split('?')}');
    print('Split: ${Uri.base.toString().split('?')[1]}');
    var params = Uri.splitQueryString(Uri.base.toString().split('?')[1]);
    print('Params = $params');
    var sessionId = params['sessionId'] ?? '';
    var page = params['page'] ?? '';
    if (sessionId.length != 32 || page.length != 32) {
      invalidParams = true;
      return;
    }

    iFrameLink = 'http://localhost:6969/devtools/$sessionId/inspector.html?ws=localhost:6970/devtools/$sessionId/page/$page';
  }

  void copy(String copy) => clippy.write(copy);

}
