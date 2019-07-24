import 'package:uuid/uuid.dart';

class SeleniumInstance {
  String sessionId;
  String ip;
  bool connectable;
  String browserName;
  String driverVersion;
  String dataDir;
  String debuggerAddress;
  String platform;
  String version;

  SeleniumInstance(this.sessionId, this.ip, this.connectable, this.browserName, this.driverVersion,
      this.dataDir, this.debuggerAddress, this.platform, this.version);

  SeleniumInstance.fromJson(Map<String, dynamic> json)
      : sessionId = json['sessionId'],
        ip = json['ip'],
        connectable = json['connectable'],
        browserName = json['browserName'],
        driverVersion = json['driverVersion'],
        dataDir = json['dataDir'],
        debuggerAddress = json['debuggerAddress'],
        platform = json['platform'],
        version = json['version'];

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'ip': ip,
        'connectable': connectable,
        'browserName': browserName,
        'driverVersion': driverVersion,
        'dataDir': dataDir,
        'debuggerAddress': debuggerAddress,
        'platform': platform,
        'version': version
      };
}
