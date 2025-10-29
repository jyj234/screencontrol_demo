import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screencontrol_demo/xmlFileGenerator/modelDefine.dart';
import '../types/videoContent.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoConfig extends StatefulWidget {
  final VideoPanel content;
  final ValueChanged<VideoPanel> onChanged;

  const VideoConfig({
    required this.content,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _VideoConfigState createState() => _VideoConfigState();
}

class _VideoConfigState extends State<VideoConfig> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.content.text != oldWidget.content.text) {
    //   _controller.text = widget.content.text;
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }
  Widget _buildVideoList(String? picPath) {
    return GestureDetector(
      onTap: picPath == null ? _addVideoItem : null,
      child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: picPath == null ? Center(child: const Icon(Icons.add, size: 40)) : VideoThumbnailWidget(videoPath: picPath)
      ),
    );
  }
  Widget _buildSettingOptions() {
    return Column(
      children: [
        _buildSettingRow('显示特技', '快速打出 >'),
        _buildSettingRow('特效速度', '16 >'),
        // _buildSettingRow('停留时间', '10', isTimeSetting: true),
        // _buildSettingRow('背景', '关闭 >'),
      ],
    );
  }
  Widget _buildSettingRow(String title, String value, {bool isTimeSetting = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (isTimeSetting)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: Colors.green),
                  onPressed: () {},
                ),
                Text(value),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: () {},
                ),
              ],
            )
          else
            Text(value),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 视频选择区域
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.content.videoUnits.length + 1,
            itemBuilder: (context, index) {
              return _buildVideoList(
                  index == widget.content.videoUnits.length ? null : widget.content
                      .videoUnits[index].file);
            },
          ),
        ),
        SizedBox(height: 16),
        // 设置选项
        _buildSettingOptions(),
      ],
    );
  }
  Future<void> _addVideoItem() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery, // 直接从相册选
      maxDuration: const Duration(minutes: 5), // 限制视频时长
    );

    if (video != null) {
      final videoUnit = VideoUnit(file: video.path,order: widget.content.videoUnits.length);
      setState(() {
        widget.onChanged(widget.content..videoUnits.add(videoUnit));
      });
      print("成功添加视频: ${video.path}");
    }
  }
}
// 新增的缩略图生成组件
class VideoThumbnailWidget extends StatefulWidget {
  final String videoPath;

  const VideoThumbnailWidget({super.key, required this.videoPath});

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late Future<File?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _generateThumbnail(widget.videoPath);
  }

  Future<File?> _generateThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 80, // 缩略图宽度
        quality: 25, // 质量
      );
      return thumbnailPath != null ? File(thumbnailPath) : null;
    } catch (e) {
      print("生成缩略图失败: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(snapshot.data!, fit: BoxFit.cover);
          } else {
            return const Center(child: Icon(Icons.error)); // 失败时显示错误图标
          }
        } else {
          return const Center(child: CircularProgressIndicator()); // 加载中显示进度条
        }
      },
    );
  }
}