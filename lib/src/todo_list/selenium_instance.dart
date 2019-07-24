import 'package:uuid/uuid.dart';

class SeleniumInstance {
  String sessionId;
  String browserName;
  String driverVersion;
  String dataDir;
  String debuggerAddress;
  String platform;
  String version;

  SeleniumInstance(this.sessionId, this.browserName, this.driverVersion,
      this.dataDir, this.debuggerAddress, this.platform, this.version);

  SeleniumInstance.fromJson(Map<String, dynamic> json)
      : sessionId = json['sessionId'],
        browserName = json['browserName'],
        driverVersion = json['driverVersion'],
        dataDir = json['dataDir'],
        debuggerAddress = json['debuggerAddress'],
        platform = json['platform'],
        version = json['version'];

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'browserName': browserName,
        'driverVersion': driverVersion,
        'dataDir': dataDir,
        'debuggerAddress': debuggerAddress,
        'platform': platform,
        'version': version
      };
}
