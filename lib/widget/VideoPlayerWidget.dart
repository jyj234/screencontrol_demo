import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class VideoPlayerWidget extends StatefulWidget {
  final String filePath;
  final bool isPlay;
  const VideoPlayerWidget({required this.filePath,this.isPlay = false});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (mounted) setState(() => _isInitialized = true);
        if(widget.isPlay) {
          // 关键：初始化完成后播放
          _controller.play();
          // 可选：设置静音绕过平台限制
          _controller.setVolume(0); // 0.0 表示静音
        }
      }).catchError((_) {
        if (mounted) setState(() => _hasError = true);
      });
    print("_VideoPlayerWidgetState initState");
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container( // 错误占位符
        color: Colors.grey[200],
        child: const Icon(Icons.videocam_off, size: 40),
      );
    }

    return _isInitialized
        ? AspectRatio( // 播放器
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Container( // 加载中占位符
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}