import 'dart:io';

import 'package:SeleniumHub/src/todo_list/selenium_instance.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../instance_manager.dart';

class InspectorWebsocketProxy {

  InstanceManager instanceManager;
  Map<String, WebSocket> webSockets = {};
  Map<Stream<dynamic>, Function> streamListeners = {};

  InspectorWebsocketProxy(this.instanceManager);

  start() async {
    var selenium = await WebSocket.connect('ws://localhost:53649/devtools/page/5CB2A06737E4B88BF509C7CB07E0FD54');

    var handler = webSocketHandler((WebSocketChannel webSocket) {
      streamTo(webSocket.stream, (message) {
        // Web -> Selenium
        // localhost:6970/devtools/b13e9757730fa66ea12cf7b315c2aeb4/ -> localhost:53649/devtools/
        selenium.add(message);
      });

      streamTo(selenium, (message) {
        // Selenium -> Web
        // localhost:53649/devtools/ -> localhost:6970/devtools/b13e9757730fa66ea12cf7b315c2aeb4/
        webSocket.sink.add(message);
      });
    });

    await shelf_io.serve(handler, 'localhost', 6970).then((server) {
      print('Serving at ws://${server.address.host}:${server.port}');
    });
  }

  void streamTo(Stream<dynamic> stream, void Function(dynamic) onData) {
    if (!streamListeners.containsKey(stream)) stream.listen((message) => streamListeners[stream](message));
    streamListeners[stream] = onData;
  }

  void startPage(SeleniumInstance instance, String page) {

  }

  void stopInstance(SeleniumInstance instance) {

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
