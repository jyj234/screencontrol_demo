import 'dart:convert';

class UdpSearchControllerResponce {
  final String targetpid;
  final String targetbarcode;
  final RemoteFunction remotefunction;

  UdpSearchControllerResponce({
    required this.targetpid,
    required this.targetbarcode,
    required this.remotefunction,
  });

  factory UdpSearchControllerResponce.fromJson(Map<String, dynamic> json) {
    return UdpSearchControllerResponce(
      targetpid: json['targetpid'] as String,
      targetbarcode: json['targetbarcode'] as String,
      remotefunction: RemoteFunction.fromJson(json['remotefunction']),
    );
  }
}

class RemoteFunction {
  final String name;
  final String? verificationcode; // 可选字段
  final String networkdevice;
  final String? tracecode; // 可选字段
  final Map<String, dynamic> output; // 动态参数容器

  RemoteFunction({
    required this.name,
    this.verificationcode,
    required this.networkdevice,
    this.tracecode,
    required this.output,
  });

  factory RemoteFunction.fromJson(Map<String, dynamic> json) {
    return RemoteFunction(
      name: json['name'] as String,
      verificationcode: json['verificationcode']?.toString(),
      networkdevice: json['networkdevice'] as String,
      tracecode: json['tracecode']?.toString(),
      output: (json['output'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v)),
    );
  }
}