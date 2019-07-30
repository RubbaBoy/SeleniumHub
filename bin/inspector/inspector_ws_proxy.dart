import 'dart:io';

import 'package:SeleniumHub/selenium_instance.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../instance_manager.dart';
import '../proxy.dart';

var client = http.Client();

Future main(List<String> args) async {

  // Proxy IN
  var app = Angel();
  var server = await AngelHttp(app).startServer(InternetAddress.loopbackIPv4, 1696);

  // 62010 // page: 74136C48BDAFEBD944BD4510BEA52438 id: 1a42f1e23c082fca934e78c5399660cb
  // 62890 // page: 46E47E951B672712C70034E95796594C id: 4475f20e532066947950933f4db44cff

  print('Listening at http://${server.address.address}:${server.port}');
}

class InspectorWebsocketProxy {

  HttpServer _server;
  Angel _app = Angel();

  InstanceManager instanceManager;
  Map<String, WebSocket> webSockets = {};
  Map<Stream<dynamic>, Function> streamListeners = {};

  Map<String, Proxy> proxies = {};

  InspectorWebsocketProxy(this.instanceManager);

  start() async {
    _app = Angel();
    _server = await AngelHttp(_app).startServer(InternetAddress.loopbackIPv4, 6970);
  }

  void streamTo(Stream<dynamic> stream, void Function(dynamic) onData) {
    if (!streamListeners.containsKey(stream)) stream.listen((message) => streamListeners[stream](message));
    streamListeners[stream] = onData;
  }

  void startInstance(SeleniumInstance instance) {
    var proxy = Proxy(client, 'ws://localhost:${instanceManager.getPort(instance)}/devtools/');
    _app.all('/devtools/${instance.sessionId}/*', proxy.handleRequest);
    proxies[instance.sessionId] = proxy;
  }

  void stopInstance(String id) {
    proxies[id]?.close();
    proxies.remove(id);
  }

//  Future<WebSocket> getWSFor(SeleniumInstance instance) async {
//    if (webSockets.containsKey(instance.sessionId)) return webSockets[instance.sessionId];
//    webSockets[instance.sessionId] = await WebSocket.connect('ws://localhost:${instanceManager.getPort(instance)}/devtools/page/5CB2A06737E4B88BF509C7CB07E0FD54');
//    return webSockets[instance.sessionId];
//  }

}
