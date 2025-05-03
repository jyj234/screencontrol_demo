import 'dart:ui';

enum ContentType { text, image, video }
abstract class ContentItem {
  final String id;
  final ContentType type;
  int zIndex;
  Offset position;
  Size size;
  static final double borderWidth = 2;

  ContentItem({
    required this.id,
    required this.type,
    this.zIndex = 0,
    this.position = Offset.zero,
    this.size = const Size(50,50),
  });
}