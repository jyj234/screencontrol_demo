import 'package:flutter/material.dart';
import '../types/textContent.dart';

class TextConfig extends StatelessWidget {
  final TextContent content;
  final ValueChanged<TextContent> onChanged;
  // final ValueChanged<bool> onFocusChange;
  const TextConfig({
    required this.content,
    required this.onChanged,
    // required this.onFocusChange,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: content.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter text',
          ),
          maxLines: 5,
          minLines: 1,
          onChanged: (value) {
            onChanged(content..text = value); // 使用级联操作更新
          },
          // onTap: () => onFocusChange(true),
          // onEditingComplete: () => onFocusChange(false),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}