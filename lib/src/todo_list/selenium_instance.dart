import 'package:uuid/uuid.dart';

class SeleniumInstance {
  Uuid uuid;
  String name;
  String ip;
  String port;
  String computer;
  String os;
  String debugUrl;

  SeleniumInstance(
      this.name, this.ip, this.port, this.computer, this.os, this.debugUrl);

  SeleniumInstance.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        ip = json['ip'],
        port = json['port'],
        computer = json['computer'],
        os = json['os'],
        debugUrl = json['debugUrl'];

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'ip': ip,
        'port': port,
        'computer': computer,
        'os': os,
        'debugUrl': debugUrl
      };
}
