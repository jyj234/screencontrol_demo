import 'package:xml/xml.dart';

import '../widget/searchScreenDialog.dart';

/// 生成播放列表 XML
String generatePlaylistXml({
  required List<ProgramInfo> programs,
}) {
  if(ScreenInfoSingleton().selectedScreen == null)
    return "";
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="utf-8"');
  builder.element('list', attributes: {
    'deviceType': '${ScreenInfoSingleton().selectedScreen?.deviceType ?? 0}',
    'screenWidth': '${ScreenInfoSingleton().selectedScreen?.width ?? 0}',
    'screenHeight': '${ScreenInfoSingleton().selectedScreen?.height ?? 0}',
  }, nest: () {
    for (final program in programs) {
      builder.element('program', attributes: {
        'order': '${program.order}',
        'playMode': '${program.playMode}',
        'priority': '${program.priority ?? 16}',
        'loop': '${program.loop ?? 0}',
        'programFile': 'programs/${program.programFile}',
        'playTime': '${program.playTime ?? 60}',
        'playCount': '${program.playCount ?? 1}',
        'integrate': '${program.integrate ?? 1}',
        'startDate': program.startDate ?? '',
        'startTime': program.startTime ?? '',
        'stopDate': program.stopDate ?? '',
        'stopTime': program.stopTime ?? '',
        'weekFlag': '${program.weekFlag ?? 127}',
        'dates': program.dates ?? '',
        'times': program.times ?? '',
      });
    }
  });

  final xmlDocument = builder.buildDocument();
  return xmlDocument.toXmlString(pretty: true);
}

/// 节目信息模型
class ProgramInfo {
  final int? order;
  final String? playMode; // '0' 或 '1'，或 'Timer'/'Counter'
  final int? priority; // 1~16，默认 16
  final int? loop; // 0~1000，默认 0
  final String programFile; // 节目文件路径
  final int? playTime; // 播放时长（秒），默认 5
  final int? playCount; // 播放次数，默认 1
  final int? integrate; // '0'/'1' 或 'no'/'yes'，默认 '1'
  final String? startDate; // 'yyyy-MM-dd'，默认 '1970-01-01'
  final String? startTime; // 'hh:mm:ss'，默认 '00:00:00'
  final String? stopDate; // 'yyyy-MM-dd'，默认 '2099-12-31'
  final String? stopTime; // 'hh:mm:ss'，默认 '23:59:59'
  final int? weekFlag; // 1~127，默认 127
  final String? dates; // 日期段，如 '2025-01-01 2025-01-05'
  final String? times; // 时间段，如 '08:00:00 12:00:00'

  ProgramInfo({
    this.order = 0,
    this.playMode = 'Counter',
    this.priority = 16,
    this.loop = 0,
    required this.programFile,
    this.playTime = 60,
    this.playCount = 1,
    this.integrate = 1,
    this.startDate,
    this.startTime,
    this.stopDate,
    this.stopTime,
    this.weekFlag,
    this.dates,
    this.times,
  });
}