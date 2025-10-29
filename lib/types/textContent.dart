import 'package:flutter/material.dart';
import '../base/contentItem.dart';

class TextContent extends ContentItem {
  String text;
  TextStyle style;
  TextContent({
    required super.id,
    super.x = 0,
    super.y = 0,
    super.width = 1.0,
    super.height = 1.0,
    this.text = '',
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    super.zIndex,
    // super.position,
    // super.size,
  }) : super(type: ContentType.text);
}