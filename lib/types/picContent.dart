import '../base/contentItem.dart';
import '../xmlFileGenerator/modelDefine.dart';

/// 图片内容项（继承自ContentItem）
class PicContent extends ContentItem {
  final int transparency;   // 透明度（0-100）
  List<PicUnit> picUnits; // 图片单元列表

  PicContent({
    required super.id,      // 从父类继承
    super.x = 0,            // X坐标（默认0）
    super.y = 0,            // Y坐标（默认0）
    super.width = 1.0,      // 宽度（默认1.0）
    super.height = 1.0,     // 高度（默认1.0）
    super.zIndex,           // 层级（继承自父类）
    this.transparency = 100,// 默认完全不透明
    List<PicUnit>? picUnits,
  }) :
        picUnits = List.of(picUnits ?? []),
        super(type: ContentType.picture); // 类型标记为图片
}