import 'package:xml/xml.dart';
import '../widget/searchScreenDialog.dart';
import 'modelDefine.dart';

/// 生成节目文件 XML（支持文字/图片/预留视频分区）
String generateProgramXml({
  required String programName,
  String bgColor = '',
  List<TextPanel>? textPanels,
  List<PicturePanel>? picturePanels,
  List<VideoPanel>? videoPanels, // 预留视频分区
}) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="utf-8"');
  builder.element('program', attributes: {
    'name': programName,
    'bgColor': bgColor,
  }, nest: () {
    // 文字分区
    for (final panel in textPanels ?? []) {
      _buildTextPanel(builder, panel);
    }

    // 图片分区
    for (final panel in picturePanels ?? []) {
      _buildPicturePanel(builder, panel);
    }

    // 预留视频分区（扩展用）
    for (final panel in videoPanels ?? []) {
      _buildVideoPanel(builder, panel);
    }
  });

  return builder.buildDocument().toXmlString(pretty: true);
}

// 构建文字分区
void _buildTextPanel(XmlBuilder builder, TextPanel panel) {
  builder.element('textpanel', attributes: {
    'x': '${panel.x}',
    'y': '${panel.y}',
    'width': '${(panel.width * ScreenInfoSingleton().selectedScreen!.width).toInt()}',
    'height': '${(panel.height * ScreenInfoSingleton().selectedScreen!.height).toInt()}',
    'zOrder': '${panel.zOrder}',
    'transparency': '${panel.transparency}',
    'stuntType': '${panel.stuntType}',
    'unitType': panel.unitType == UnitType.image ? 'image' : 'text',
  }, nest: () {

    if (panel.panelType == PanelType.pic) {
      final unit = panel.imageUnit?? ImageUnit(order: 0, filePath: "");
        builder.element('imageUnit', attributes: {
          'order': '${unit.order}',
          'file': unit.filePath,
          'stuntSpeed': '${unit.stuntSpeed}',
          'stayTime': '${unit.stayTime}',
        });
    } else {
      // for (final unit in panel.textUnits ?? []) {
      final unit = panel.textUnit?? TextUnit(order: 0,content: "");
      builder.element('textUnit', attributes: {
          'order': '${unit.order}',
          'content': unit.content,
          'stuntSpeed': '${unit.stuntSpeed}',
          'stayTime': '${unit.stayTime}',
          'bgColor': unit.bgColor,
          'fontColor': unit.fontColor,
          'fontName': unit.fontName,
          'fontSize': '${unit.fontSize}',
          'fontSizeType': unit.fontSizeType == FontSizeType.pixel ? 'pixel' : 'point',
          'fontAttributes': unit.fontAttributes.join('&'),
        });
      // }
    }
  });
}

// 构建图片分区
void _buildPicturePanel(XmlBuilder builder, PicturePanel panel) {
  builder.element('picturepanel', attributes: {
    'x': '${panel.x}',
    'y': '${panel.y}',
    'width': '${(panel.width * ScreenInfoSingleton().selectedScreen!.width).toInt()}',
    'height': '${(panel.height * ScreenInfoSingleton().selectedScreen!.height).toInt()}',
    'zOrder': '${panel.zOrder}',
    'transparency': '${panel.transparency}',
  }, nest: () {
    for (final unit in panel.picUnits) {

      builder.element('picUnit', attributes: {
        'order': '${unit.order}',
        'file': unit.uploadFilePath,
        'fileType': unit.fileType,
        'stuntType': '${unit.stuntType}',
        'stuntSpeed': '${unit.stuntSpeed}',
        'stayTime': '${unit.stayTime}',
      });
    }
  });
}

// 预留视频分区（扩展结构）
void _buildVideoPanel(XmlBuilder builder, VideoPanel panel) {
  builder.element('videopanel', attributes: {
    'videoType': '${panel.videoType.value}',
    'volumeMode': '${panel.volumeMode.value}',
    'rotationMode': '${panel.rotationMode}',
    'scaleMode': "${panel.scaleMode.value}",
    'x': '${panel.x}',
    'y': '${panel.y}',
    'width': '${(panel.width * ScreenInfoSingleton().selectedScreen!.width).toInt()}',
    'height': '${(panel.height * ScreenInfoSingleton().selectedScreen!.height).toInt()}',
    'z': '${panel.zOrder}',
    't': '${panel.transparency}',
  }, nest: () {
    for (final unit in panel.videoUnits) {
      builder.element('videoUnit', attributes: {
        'file': unit.file,
        'source': '${unit.source}',
        'playTime': unit.playTime.toString(),
        'volume': unit.volume.toString(),
        'order': '${unit.order}',
      });
    }
  });
}
