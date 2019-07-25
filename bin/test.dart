import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const bool DEBUG = false;

Future main() async {
//  var selenium = await WebSocket.connect('ws://localhost:53649/devtools/page/5CB2A06737E4B88BF509C7CB07E0FD54');
  var selenium = await WebSocket.connect(
      'ws://localhost:53649/devtools/page/5CB2A06737E4B88BF509C7CB07E0FD54');

  var handler = webSocketHandler((WebSocketChannel webSocket) {
    streamTo(webSocket.stream, (message) => selenium.add(message));
    streamTo(selenium, (message) => webSocket.sink.add(message));
  });

  shelf_io.serve(handler, 'localhost', 6970).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });
}

Map<Stream<dynamic>, Function> streamListeners = {};

void streamTo(Stream<dynamic> stream, void Function(dynamic) onData) {
  if (!streamListeners.containsKey(stream)) stream.listen((message) => streamListeners[stream](message));
  streamListeners[stream] = onData;
}
