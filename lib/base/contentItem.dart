import 'dart:ui';

enum ContentType { text, picture, video }
abstract class ContentItem {
  final String id;
  final ContentType type;
  int x = 0;
  int y = 0;
  final double width;
  final double height;

  int zIndex;
  // Offset position;
  // Size size;
  static final double borderWidth = 2;

  ContentItem({
    required this.id,
    required this.type,
    this.x = 0,
    this.y = 0,
    this.height = 1.0,
    this.width = 1.0,

    this.zIndex = 0,
    // this.position = Offset.zero,
    // this.size = const Size(50,50),
  });
}