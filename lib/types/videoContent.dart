import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../base/contentItem.dart';
import '../xmlFileGenerator/modelDefine.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:path/path.dart' as path;

Future<String?> convertVideoToH264(String inputVideoPath) async {
  final outputDir = await getTemporaryDirectory();
  final outputFileName = 'converted_${DateTime.now().millisecondsSinceEpoch}.mp4';
  final outputPath = path.join(outputDir.path, outputFileName);

  String command = '-y -i "$inputVideoPath" '
      '-c:v libx264 -vf scale=182:102 -preset ultrafast -crf 23 -r 30 -c:a aac '
      '"$outputPath"';

  // 使用 Completer 将回调转换为 Future
  final completer = Completer<String?>();

  FFmpegKit.executeAsync(command, (session) async {
    final returnCode = await session.getReturnCode();
    if (returnCode!.isValueSuccess()) {
      completer.complete(outputPath); // 转码成功，返回输出路径
    } else {
      completer.completeError(Exception('转码失败，错误码：${returnCode.getValue()}'));
    }
  });

  return completer.future;
}
/// 视频内容项（继承自ContentItem）
class VideoContent extends ContentItem {
  final int transparency;   // 透明度（0-100）
  final String? clone;      // 克隆分区坐标及宽高配置
  final dynamic videoType = 'local';  // 视频类型：'local'/0 或 'capture'/1
  dynamic volumeMode; // 静音模式：'Unmute'/0 或 'Mute'/1
  final int rotationMode;   // 旋转角度（0/90/180/270）
  final dynamic scaleMode = "window";  // 缩放模式：'window'/1 等
  final List<VideoUnit> videoUnits; // 视频子单元列表

  VideoContent({
    required super.id,
    super.x = 0,
    super.y = 0,
    super.width = 1,
    super.height = 1,
    super.zIndex,
    this.transparency = 100,
    this.clone,
    this.volumeMode = 'Mute',
    this.rotationMode = 0,
    List<VideoUnit>? videoUnits,
  }) :
        videoUnits = List.of(videoUnits ?? []),
        super(type: ContentType.video); // 类型标记为视频

}