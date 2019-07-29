import 'dart:io' show Platform;

import 'dart:io';

void main(List<String> args) {
  DriverController().startDriver();
}

class DriverController {

  bool DRIVER_STARTED = false;

  String driverLocation;

  void startDriver() async {
    if (!Platform.isWindows && !Platform.isLinux) {
      print('Error: Unsupported platform!');
      return;
    }

    var process = await Process.start(driverLocation, ['--port=4444'], mode: ProcessStartMode.detachedWithStdio);
    print('Started the chromedriver as PID ${process.pid}');
  }

  void stopDriver() async {
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/F', '/IM', 'chromedriver.exe']);
    } else if (Platform.isLinux) {
      await Process.run('killall', ['chromedriver']);
    } else {
      print('Error: Unsupported platform!');
    }

    print('Stopped the chromedriver');
  }

  Future<bool> isDriverRunning() async {
    if (Platform.isWindows) {
      var result = Process.runSync('tasklist', []);
      return DRIVER_STARTED = result.stdout.contains('chromedriver.exe');
    } else if (Platform.isLinux) {
      var result = await Process.runSync('ps', ['aux']);
      return DRIVER_STARTED = result.stdout.contains('chromedriver');
    } else {
      print('Error: Unsupported platform!');
      return DRIVER_STARTED = false;
    }
  }
}
