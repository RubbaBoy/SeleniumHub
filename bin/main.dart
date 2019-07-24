import 'package:SeleniumHub/channel.dart';
import 'package:aqueduct/aqueduct.dart';

Future main() async {
  var app = Application<AppChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;
  await app.start();
}