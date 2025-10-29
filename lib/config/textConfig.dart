import 'package:flutter/material.dart';
import 'package:screencontrol_demo/xmlFileGenerator/modelDefine.dart';
import '../types/textContent.dart';

class TextConfig extends StatefulWidget {
  final TextPanel content;
  final ValueChanged<TextPanel> onChanged;

  const TextConfig({
    required this.content,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _TextConfigState createState() => _TextConfigState();
}

class _TextConfigState extends State<TextConfig> {
  late TextEditingController _controller;
  bool _singleLineDisplay = false;
  bool _backgroundEnabled = false;
  bool _loopEnabled = false;
  int _characterSpacing = 0;
  int _lineSpacing = 1;
  int _displayEffect = 5;
  int _effectSpeed = 3;
  final List<int> _spacingOptions = [
    for (int i = 0; i <= 10; i++) i,
    for (int i = 20; i <= 200; i += 10) i,
  ];
  final List<int> _lineSpacingOptions = [
    for (int i = 0; i <= 100; i++) i,
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content.textUnit?.content);
    _singleLineDisplay = widget.content.singleLineDisplay;
    _backgroundEnabled = widget.content.backgroundEnabled;
    _loopEnabled = widget.content.loopEnabled;
    _characterSpacing = widget.content.characterSpacing;
    _lineSpacing = widget.content.lineSpacing;
    _displayEffect = widget.content.stuntType;
    _effectSpeed = widget.content.effectSpeed;
  }

  @override
  void didUpdateWidget(covariant TextConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content.textUnit?.content != oldWidget.content.textUnit?.content) {
      _controller.text = widget.content.textUnit?.content ?? "";
    }
    _singleLineDisplay = widget.content.singleLineDisplay;
    _backgroundEnabled = widget.content.backgroundEnabled;
    _loopEnabled = widget.content.loopEnabled;
    _characterSpacing = widget.content.characterSpacing;
    _lineSpacing = widget.content.lineSpacing;
    _displayEffect = widget.content.stuntType;
    _effectSpeed = widget.content.effectSpeed;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateContent() {
    widget.content.textUnit?.content = _controller.text;
    widget.content.singleLineDisplay = _singleLineDisplay;
    widget.content.backgroundEnabled = _backgroundEnabled;
    widget.content.loopEnabled = _loopEnabled;
    widget.content.characterSpacing = _characterSpacing;
    widget.content.lineSpacing = _lineSpacing;
    widget.content.stuntType = _displayEffect;
    widget.content.effectSpeed = _effectSpeed;
    widget.onChanged(widget.content);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _controller,
          autofocus: false,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter text',
          ),
          maxLines: 5,
          minLines: 1,
          onChanged: (value) {
            updateContent();
          },
        ),
        SwitchListTile(
          title: Text('单行显示'),
          value: _singleLineDisplay,
          onChanged: (value) {
            setState(() {
              _singleLineDisplay = value;
              updateContent();
            });
          },
        ),
        ListTile(
          title: Text('背景'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Switch(
                value: _backgroundEnabled,
                onChanged: (value) {
                  setState(() {
                    _backgroundEnabled = value;
                    updateContent();
                  });
                },
              ),
              // Text(_backgroundEnabled ? '开启' : '关闭'),
            ],
          ),
        ),
        SwitchListTile(
          title: Text('首尾相连'),
          value: _loopEnabled,
          onChanged: (value) {
            setState(() {
              _loopEnabled = value;
              updateContent();
            });
          },
        ),
        Row(
          children: <Widget>[
            Text("字间距"),
            Spacer(),
              DropdownButton<int>(
                menuMaxHeight: 400,
                // itemHeight: 10,
                value: _characterSpacing,
                items: _spacingOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Container(
                      height: 20, // 设置每一项的高度为40像素
                      alignment: Alignment.topLeft,
                      child: Text("$value"),
                    ),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _characterSpacing = newValue!;
                    updateContent();
                  });
                },
              ),
          ],
        ),
        Row(
          children: <Widget>[
            Text("行间距"),
            Spacer(),
            DropdownButton<int>(
              menuMaxHeight: 400,
              value: _lineSpacing,
              items: _lineSpacingOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _lineSpacing = newValue!;
                  updateContent();
                });
              },
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text("显示特技"),
            Spacer(),
            DropdownButton<int>(
              menuMaxHeight: 400,
              value: _displayEffect,
              items: List.generate(stuntTypeOptions.length, (index) {
                return DropdownMenuItem<int>(
                  value: index, // 保存的是下标值
                  child: Text(stuntTypeOptions[index]), // 显示中文描述
                );
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _displayEffect = newValue;
                    updateContent();
                  });
                }
              },
            ),
          ],
        ),
        ListTile(
          title: Text('特技速度'),
          trailing: Text('$_effectSpeed >'),
          onTap: () {
            // Implement speed selection logic here
            // For example, show a dialog to select the effect speed
          },
        ),
      ],
    );
  }
}