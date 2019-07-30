import 'dart:io';

import 'package:SeleniumHub/selenium_instance.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:http/http.dart' as http;

import '../instance_manager.dart';
import '../proxy.dart';

class InspectorWebsocketProxy {

  var client = http.Client();
  HttpServer _server;
  Angel _app = Angel();

  InstanceManager instanceManager;
  Map<String, WebSocket> webSockets = {};
  Map<Stream<dynamic>, Function> streamListeners = {};

  Map<String, Proxy> proxies = {};

  InspectorWebsocketProxy(this.instanceManager);

  start() async {
    _app = Angel();
    _server = await AngelHttp(_app).startServer('0.0.0.0', 6970);
  }

  void streamTo(Stream<dynamic> stream, void Function(dynamic) onData) {
    if (!streamListeners.containsKey(stream)) stream.listen((message) => streamListeners[stream](message));
    streamListeners[stream] = onData;
  }

  void startInstance(SeleniumInstance instance) {
    var proxy = Proxy(client, 'ws://localhost:${instanceManager.getPort(instance)}/devtools/');
    print('Started websocket proxy from  /devtools/${instance.sessionId}/*  to  ws://localhost:${instanceManager.getPort(instance)}/devtools/');
    _app.all('/devtools/${instance.sessionId}/*', proxy.handleRequest);
    proxies[instance.sessionId] = proxy;
  }

  void stopInstance(String id) {
    proxies[id]?.close();
    proxies.remove(id);
  }
}
