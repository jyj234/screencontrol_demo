import 'dart:io';

enum PanelType {text,pic,video}
enum UnitType { image, text }
enum FontSizeType { pixel, point }
class CommonPanel{
  int x;
  int y;
  double width;
  double height;
  int zOrder;
  int transparency;
  final PanelType panelType;
  CommonPanel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.panelType,
    this.zOrder = 0,
    this.transparency = 100,
  });
}
class TextPanel extends CommonPanel{
  final ImageUnit? imageUnit;
  final TextUnit? textUnit;
  int stuntType = 5;
  final UnitType unitType;

  bool singleLineDisplay = true;
  bool backgroundEnabled = false;
  bool loopEnabled = true;
  int characterSpacing = 0;
  int lineSpacing = 0;
  int effectSpeed = 0;


  TextPanel({
    super.panelType = PanelType.text,
    super.x = 0,
    super.y = 0,
    super.width = 1.0,
    super.height = 1.0,
    super.zOrder = 0,
    super.transparency = 100,
    this.unitType = UnitType.text,
    this.imageUnit,
    this.textUnit,
  });
}

class ImageUnit {
  final int order;
  final String filePath;
  final int stuntSpeed;
  final int stayTime;

  ImageUnit({
    required this.order,
    required this.filePath,
    this.stuntSpeed = 16,
    this.stayTime = 1,
  });
}

class TextUnit{
  int order;
  String content;
  int stuntSpeed;
  int stayTime;
  String bgColor;
  String fontColor;
  String fontName;
  int fontSize;
  FontSizeType fontSizeType;
  List<String> fontAttributes;

  TextUnit({
    this.order = 0,
    required this.content,
    this.stuntSpeed = 16,
    this.stayTime = 1,
    this.bgColor = '0x00000000',
    this.fontColor = '0xFFFFFFFF',
    this.fontName = 'Arial',
    this.fontSize = 16,
    this.fontSizeType = FontSizeType.pixel,
    this.fontAttributes = const ['normal'],
  });
}

class PicturePanel extends CommonPanel{
  List<PicUnit> picUnits;

  PicturePanel({
    super.panelType = PanelType.pic,
    super.x = 0,
    super.y = 0,
    super.width = 1.0,
    super.height = 1.0,
    super.zOrder = 0,
    super.transparency = 100,
    List<PicUnit>? picUnits,
  }): picUnits = picUnits ?? [];
}

class PicUnit {
  int order;
  String filePath;
  String uploadFilePath;
  final String fileType;
  int stuntType;
  int stuntSpeed;
  int stayTime;

  int rotationAngel = 0;

  PicUnit({
    this.order = 0,
    required this.filePath,
    this.fileType = 'jpg',
    this.stuntType = 0,
    this.stuntSpeed = 16,
    this.stayTime = 1,
    this.uploadFilePath = "",
  });
}
// 视频类型枚举
enum VideoType {
  local(0),    // 对应文档 'local'/0
  capture(1);  // 对应文档 'capture'/1

  final int value;
  const VideoType(this.value);
}

// 音量模式枚举
enum VolumeMode {
  unmute(0),   // 对应文档 'Unmute'/0
  mute(1);     // 对应文档 'Mute'/1

  final int value;
  const VolumeMode(this.value);
}

// 缩放模式枚举
enum ScaleMode {
  original(0), // 文档注明 Y系列暂不支持
  window(1);   // 对应文档 'window'/1

  final int value;
  const ScaleMode(this.value);
}
class VideoPanel extends CommonPanel{
  final String? clone;    // 新增克隆坐标
  final VideoType videoType; // 类型改为枚举
  final VolumeMode volumeMode; // 新增静音模式
  final int rotationMode; // 新增旋转角度
  final ScaleMode scaleMode; // 新增缩放模式
  List<VideoUnit> videoUnits;

  VideoPanel({
    super.panelType = PanelType.video,
    super.x = 0,
    super.y = 0,
    super.width = 1.0,
    super.height = 1.0,
    super.zOrder = 0,
    super.transparency = 100,
    this.clone,
    this.videoType = VideoType.local,
    this.volumeMode = VolumeMode.unmute,
    this.rotationMode = 0,
    this.scaleMode = ScaleMode.window,
    List<PicUnit>? picUnits,
  }) : videoUnits = [],
        assert(transparency >= 0 && transparency <= 100, '透明度范围 0~100'),
        assert(rotationMode == 0 || rotationMode == 90
            || rotationMode == 180 || rotationMode == 270, '非法旋转角度'),
        assert(clone == null || clone.split(',').length <= 3, '最多克隆3个');

}
class VideoUnit {
  int order;      // 播放顺序 0~127
  String file;    // 对应文档 file 属性（原 filePath）
  final int source;     // 新增外部输入类型（Y系列暂不支持）
  final int playTime;   // 新增播放时长（原 loop 属性不准确）
  final int volume;     // 新增音量控制

  VideoUnit({
    required this.order,
    required this.file,
    this.source = 0,     // 默认值对应文档 'cvbs'/0
    this.playTime = 0,   // 0表示持续播放
    this.volume = 50,
  }) : assert(order >= 0 && order <= 127, 'order范围0~127'),
        assert(volume >= 0 && volume <= 100, '音量范围0~100'),
        assert(playTime >= 0, '播放时长不能为负');
}

final List<String> stuntTypeOptions = [
  "快速打出",
  "向上推入",
  "向下推入",
  "向左推入",
  "向右推入",
  "向下移入",
  "向上移入",
  "向右移入",
  "向左移入",
  "向上堆积",
  "向下堆积",
  "向左堆积",
  "向右堆积",
  "向上拉幕",
  "向下拉幕",
  "向左拉幕",
  "向右拉幕",
  "左上角拉幕",
  "右上角拉幕",
  "左下角拉幕",
  "右下角拉幕",
  "四周往中心拉幕",
  "四角往中心拉幕",
  "中心往四角拉幕",
  "左右交叉拉幕",
  "上下交叉拉幕",
  "垂直百叶拉幕",
  "水平百叶拉幕"
];

final List<int> stuntSpeedOptions = [
  for (int i = 0; i <= 16; i++) i,
];
final List<int> stayTimeOptions = [
  for (int i = 0; i <= 100; i++) i,
];