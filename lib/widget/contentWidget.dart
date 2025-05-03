
import '../base/contentItem.dart';
import 'package:flutter/material.dart';

import '../types/textContent.dart';

class ContentWidget extends StatelessWidget {
  final ContentItem item;
  final bool isSelected;
  final VoidCallback onTap;


  const ContentWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? ContentItem.borderWidth : 0,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (item.type) {
      case ContentType.text:
        return _buildTextContent(item as TextContent);
      case ContentType.image:
        return _buildTextContent(item as TextContent);
      case ContentType.video:
        return _buildTextContent(item as TextContent);
    // ...其他类型...
    }
  }

  Widget _buildTextContent(TextContent content) {
    return SizedBox(
      width: content.size.width - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      height: content.size.height - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      child: Text(
        content.text,
        style: content.style,
      ),
    );
  }

// ...其他内容类型的构建方法...
}