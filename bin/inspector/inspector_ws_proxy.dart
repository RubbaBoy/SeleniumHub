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

  // /devtools/page/46E47E951B672712C70034E95796594C
  var proxy1 = Proxy(client, 'ws://localhost:62010/devtools/');
  app.all('/devtools/1a42f1e23c082fca934e78c5399660cb/*', proxy1.handleRequest);

//  var proxy2 = Proxy(client, Uri.parse('http://localhost:62890'), publicPath: '/devtools');
//  app.all('/devtools/1a42f1e23c082fca934e78c5399660cb/*', proxy2.handleRequest);

  print('Listening at http://${server.address.address}:${server.port}');
}

class InspectorWebsocketProxy {

  AngelHttp _server;
  Angel _app = Angel();

  InstanceManager instanceManager;
  Map<String, WebSocket> webSockets = {};
  Map<Stream<dynamic>, Function> streamListeners = {};

  Map<String, Proxy> proxies = {};

  InspectorWebsocketProxy(this.instanceManager);

  start() async {
//    var selenium = await WebSocket.connect('ws://localhost:53649/devtools/page/5CB2A06737E4B88BF509C7CB07E0FD54');
//
//    var handler = webSocketHandler((WebSocketChannel webSocket) {
//      streamTo(webSocket.stream, (message) {
//        // Web -> Selenium
//        // localhost:6970/devtools/b13e9757730fa66ea12cf7b315c2aeb4/ -> localhost:53649/devtools/
//        selenium.add(message);
//      });
//
//      streamTo(selenium, (message) {
//        // Selenium -> Web
//        // localhost:53649/devtools/ -> localhost:6970/devtools/b13e9757730fa66ea12cf7b315c2aeb4/
//        webSocket.sink.add(message);
//      });
//    });
//
//    await shelf_io.serve(handler, 'localhost', 6970).then((server) {
//      print('Serving at ws://${server.address.host}:${server.port}');
//    });
  }

  void streamTo(Stream<dynamic> stream, void Function(dynamic) onData) {
    if (!streamListeners.containsKey(stream)) stream.listen((message) => streamListeners[stream](message));
    streamListeners[stream] = onData;
  }

  void startInstance(SeleniumInstance instance) {

//    var proxyy = Proxy(client, Uri.parse('ws://localhost:62010'));
//    _app.all('/*', proxyy.handleRequest);
//
//    proxies[instance.sessionId] = Proxy(client, Uri.parse('ws://localhost:${instanceManager.getPort(instance)}'));
  }

  void stopInstance(String id) {
    proxies[id]?.close();
    proxies.remove(id);
  }

  Future<WebSocket> getWSFor(SeleniumInstance instance) async {
    if (webSockets.containsKey(instance.sessionId)) return webSockets[instance.sessionId];
    webSockets[instance.sessionId] = await WebSocket.connect('ws://localhost:${instanceManager.getPort(instance)}/devtools/page/5CB2A06737E4B88BF509C7CB07E0FD54');
    return webSockets[instance.sessionId];
  }

  String webToSelenium(String url) {

  }

  String seleniumToWeb(String url) {

  }

}
