import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screencontrol_demo/xmlFileGenerator/modelDefine.dart';
import '../types/picContent.dart';

class PicConfig extends StatefulWidget {
  final PicturePanel content;
  final ValueChanged<PicturePanel> onChanged;

  const PicConfig({
    required this.content,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _PicConfigState createState() => _PicConfigState();
}

class _PicConfigState extends State<PicConfig> {
  int _rotationAngle = 0;
  String displayEffect = '向上镭射';
  int effectSpeed = 16;
  int pauseTime = 10;
  bool backgroundEnabled = false;
  bool borderEnabled = false;
  int _selectedIndex = -1;

  List<String> displayEffects = ['向上镭射', '向下镭射', '旋转'];
  final List<int> _rotationAngleOptions = [
    0,90,180,270
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PicConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.content.text != oldWidget.content.text) {
    //   _controller.text = widget.content.text;
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }
  Widget _buildPicList(String? picPath,int index) {
    return GestureDetector(
      onTap: (){
        if(picPath == null) {
          _addImageItem();
        }
        else{
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
                color: index == _selectedIndex ? Colors.green : Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: picPath == null ? Center(child: Text('+')) : Image.file(File(picPath), fit: BoxFit.cover)
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 图片选择区域
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.content.picUnits.length + 1,
            itemBuilder: (context, index) {
              return _buildPicList(
                  index == widget.content.picUnits.length ? null : widget.content
                      .picUnits[index].filePath,index);
            },
          ),
        ),
        if(_selectedIndex >= 0)
          Column(
            children: [
              Row(
                children: <Widget>[
                  Text("旋转角度"),
                  Spacer(),
                  DropdownButton<int>(
                    menuMaxHeight: 400,
                    value: widget.content.picUnits[_selectedIndex].rotationAngel,
                    items: _rotationAngleOptions.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value°'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        widget.content.picUnits[_selectedIndex].rotationAngel =
                        newValue!;
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
                    value: widget.content.picUnits[_selectedIndex].stuntType,
                    items: List.generate(stuntTypeOptions.length, (index) {
                      return DropdownMenuItem<int>(
                        value: index, // 保存的是下标值
                        child: Text(stuntTypeOptions[index]), // 显示中文描述
                      );
                    }),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          widget.content.picUnits[_selectedIndex].stuntType = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("特技速度"),
                  Spacer(),
                  DropdownButton<int>(
                    menuMaxHeight: 400,
                    value: widget.content.picUnits[_selectedIndex].stuntSpeed,
                    items: List.generate(stuntSpeedOptions.length, (index) {
                      return DropdownMenuItem<int>(
                        value: stuntSpeedOptions[index], // 保存的是下标值
                        child: Text(stuntSpeedOptions[index].toString()), // 显示中文描述
                      );
                    }),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          widget.content.picUnits[_selectedIndex].stuntSpeed = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("停留时间"),
                  Spacer(),
                  DropdownButton<int>(
                    menuMaxHeight: 400,
                    value: widget.content.picUnits[_selectedIndex].stayTime,
                    items: List.generate(stayTimeOptions.length, (index) {
                      return DropdownMenuItem<int>(
                        value: stayTimeOptions[index], // 保存的是下标值
                        child: Text(stayTimeOptions[index].toString()), // 显示中文描述
                      );
                    }),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          widget.content.picUnits[_selectedIndex].stayTime = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
  Future<void> _addImageItem() async {
    final picker = ImagePicker();

    // 从相册选择图片
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery, // 从相册选择
      maxWidth: 1024,             // 可选：限制图片尺寸
      maxHeight: 1024,
    );

    if (image != null) {
      // 将选择的图片保存到状态变量，并更新UI
      final picUnit = PicUnit(filePath: image.path);
      setState(() {
        widget.onChanged(widget.content..picUnits.add(picUnit));
      });
      // 这里可以处理图片上传或其他逻辑
      print('图片路径: ${image.path}');
      if(_selectedIndex == -1) {
        _selectedIndex = 0;
      }
    } else {
      // 用户取消了选择
      print('未选择图片');
    }
  }
}