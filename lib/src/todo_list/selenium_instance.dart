import 'package:uuid/uuid.dart';

class SeleniumInstance {
  String sessionId;
  String ip;
  String browserName;
  String driverVersion;
  String dataDir;
  String debuggerAddress;
  String platform;
  String version;
  String screenshot; // May be null, is only set from server
  String revisionId; // A UUID that should change upon each change, i.e. screenshot change
  String url;

  SeleniumInstance(this.sessionId, this.ip, this.browserName, this.driverVersion,
      this.dataDir, this.debuggerAddress, this.platform, this.version, this.screenshot, this.url) :
      revisionId = Uuid().v4();

  SeleniumInstance.fromJson(Map<String, dynamic> json)
      : sessionId = json['sessionId'],
        ip = json['ip'],
        browserName = json['browserName'],
        driverVersion = json['driverVersion'],
        dataDir = json['dataDir'],
        debuggerAddress = json['debuggerAddress'],
        platform = json['platform'],
        version = json['version'],
        screenshot = json['screenshot'],
        revisionId = json['revisionId'],
        url = json['url'];

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'ip': ip,
        'browserName': browserName,
        'driverVersion': driverVersion,
        'dataDir': dataDir,
        'debuggerAddress': debuggerAddress,
        'platform': platform,
        'version': version,
        'screenshot': screenshot,
        'revisionId': revisionId,
        'url': url
      };

  void refreshRevision() {
    revisionId = Uuid().v4();
    print('Refreshed revision to $revisionId');
  }
}
