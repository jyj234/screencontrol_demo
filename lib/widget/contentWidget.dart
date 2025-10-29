
import 'dart:async';
import 'dart:io';

import 'package:screencontrol_demo/xmlFileGenerator/modelDefine.dart';

import '../base/contentItem.dart';
import 'package:flutter/material.dart';

import '../types/videoContent.dart';
import '../types/picContent.dart';
import '../types/textContent.dart';
import 'VideoPlayerWidget.dart';

class ContentWidget extends StatelessWidget {
  final CommonPanel item;
  final bool isSelected;
  final VoidCallback onTap;
  final double screenPreviewW;
  final double screenPreviewH;
  final bool isListItem;
  final PageController? pageController;
  final int? currentIndex;
  final Function(int)? moveToIndex;

  const ContentWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.screenPreviewW,
    required this.screenPreviewH,
    required this.isListItem,
    this.pageController,
    this.currentIndex,
    this.moveToIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
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
    switch (item.panelType) {
      case PanelType.text:
        return _buildTextContent(item as TextPanel);
      case PanelType.pic:
        return _buildImageItem(item as PicturePanel);
      case PanelType.video:
        return _buildVideoItem(item as VideoPanel);
      default:
        return Container();
    }
  }

  Widget _buildTextContent(TextPanel content) {
    return SizedBox(
      width: content.width * screenPreviewW - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      height: content.height * screenPreviewH - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          content.textUnit?.content ?? "",
          style: TextStyle(color: Colors.red, letterSpacing: content.characterSpacing.toDouble()),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildImageItem(PicturePanel content) {
    final String? filePath = content.picUnits.isNotEmpty
        ? content.picUnits[0].filePath
        : null;

    return SizedBox(
      width: content.width * screenPreviewW - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      height: content.height * screenPreviewH - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      child: !isListItem && pageController != null && currentIndex != null && moveToIndex != null
          ? PageView.builder(
        controller: pageController!,
        itemCount: content.picUnits.length,
        onPageChanged: (index) {
          moveToIndex!(index);
        },
        itemBuilder: (context, index) {
          return Image.file(File(content.picUnits[index].filePath), fit: BoxFit.cover);
        },
      )
          : (filePath != null && filePath.isNotEmpty)
          ? Image.file(
        File(filePath),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container( // 加载中的占位符
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container( // 错误时的统一占位符
            color: Colors.grey[200],
            child: const Icon(Icons.photo, size: 40),
          );
        },
      )
          : Container( // 无图片时的默认占位符
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.add_a_photo, size: 40)),
      ),
    );
  }

  Widget _buildVideoItem(VideoPanel content) {
    final String? filePath = content.videoUnits.isNotEmpty
        ? content.videoUnits[0].file
        : null;

    return SizedBox(
      width: content.width * screenPreviewW - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      height: content.height * screenPreviewH - 2 * ContentItem.borderWidth * (isSelected ? 1 : 0),
      child: (filePath != null && filePath.isNotEmpty)
          ? VideoPlayerWidget(filePath: filePath, isPlay: !isListItem,) // 视频播放组件
          : Container( // 无视频时的默认占位符
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.videocam, size: 40)),
      ),
    );
  }
}
class CarouselContentWidget extends StatefulWidget {
  CommonPanel item;
  final bool isSelected;
  final VoidCallback onTap;
  final double screenPreviewW;
  final double screenPreviewH;
  final bool isListItem;

  CarouselContentWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.screenPreviewW,
    required this.screenPreviewH,
    this.isListItem = true,
  });

  @override
  _CarouselContentWidgetState createState() => _CarouselContentWidgetState();
}

class _CarouselContentWidgetState extends State<CarouselContentWidget> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  int? _lastStayTime; // 记录当前图片的停留时间

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(CarouselContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当图片列表变化时重新启动定时器
    if (widget.item != oldWidget.item) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    if (widget.item.panelType != PanelType.pic) return;

    // 获取当前图片的停留时间（默认3秒）
    int currentStayTime = 10;
    int listLength = 0;
    if(widget.item.panelType == PanelType.pic) {
      final picPanel = widget.item as PicturePanel;
      if(picPanel.picUnits.length == 0)
        return;
      currentStayTime =  picPanel.picUnits[_currentIndex].stayTime ?? 3;
      listLength  = picPanel.picUnits.length;
    }
    // else if(widget.item.panelType == PanelType.video){
    //   final videoPanel = widget.item as VideoPanel;
    //   currentStayTime =  videoPanel.videoUnits[_currentIndex]. ?? 3;
    //   listLength  = videoPanel..length;
    // }
    _lastStayTime = currentStayTime;

    _autoScrollTimer = Timer(Duration(seconds: currentStayTime), () {
      if (!mounted) return;

      final nextIndex = (_currentIndex + 1) % listLength;

      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() => _currentIndex = nextIndex);
      _startAutoScroll(); // 递归调用
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _moveToIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
      _startAutoScroll(); // 切换图片后重新开始计时
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentWidget(
      item: widget.item,
      isSelected: widget.isSelected,
      onTap: widget.onTap,
      screenPreviewW: widget.screenPreviewW,
      screenPreviewH: widget.screenPreviewH,
      isListItem: widget.isListItem,
      pageController: _pageController,
      currentIndex: _currentIndex,
      moveToIndex: _moveToIndex,
    );
  }
}