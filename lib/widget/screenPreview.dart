import 'package:flutter/material.dart';
import '../base/contentItem.dart';
import '../xmlFileGenerator/modelDefine.dart';
import 'contentWidget.dart';

/// 可堆叠内容组件
class ScreenPreview extends StatefulWidget {
  /// 内容项列表的 ValueNotifier
  final ValueNotifier<List<CommonPanel>> itemsNotifier;

  /// 背景颜色（默认为黑色）
  final Color backgroundColor;

  /// 选中项的边框颜色
  final Color selectedBorderColor;

  /// 未选中项的边框颜色
  final Color unselectedBorderColor;

  /// 控制面板的背景颜色
  final Color controlPanelColor;

  /// 是否显示控制面板
  final bool showControlPanel;

  final CommonPanel? selectedItem;

  final int scrrenW;
  final int scrrenH;


  const ScreenPreview({
    super.key,
    required this.itemsNotifier,
    required this.onItemSelected,
    required this.selectedItem,
    required this.scrrenW,
    required this.scrrenH,

    this.backgroundColor = Colors.black,
    this.selectedBorderColor = Colors.blueAccent,
    this.unselectedBorderColor = Colors.grey,
    this.controlPanelColor = Colors.black54,
    this.showControlPanel = false,

  });
  final Function(dynamic) onItemSelected;

  @override
  State<ScreenPreview> createState() => _ScreenPreviewState();
}

class _ScreenPreviewState extends State<ScreenPreview> {
  @override
  void initState() {
    super.initState();
    widget.itemsNotifier.addListener(_handleItemsChange);
  }

  @override
  void dispose() {
    widget.itemsNotifier.removeListener(_handleItemsChange);
    super.dispose();
  }

  void _handleItemsChange() {
    setState(() {});
  }

  void _handleItemSelected(dynamic item) {
    widget.onItemSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.itemsNotifier.value;
    final sortedItems = List<CommonPanel>.from(items)
      ..sort((a, b) => a.zOrder.compareTo(b.zOrder));

    return Container(
      width: widget.scrrenW.toDouble(),
      height: widget.scrrenH.toDouble(),
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          for (var i = 0; i < sortedItems.length; i++)
            Positioned(
              left: sortedItems[i].x.toDouble(),
              top: sortedItems[i].y.toDouble(),
              child: CarouselContentWidget(
                onTap: () => _handleItemSelected(items.indexOf(sortedItems[i])),
                item: sortedItems[i],
                isSelected: widget.selectedItem == sortedItems[i],
                screenPreviewH: widget.scrrenH.toDouble(),
                screenPreviewW: widget.scrrenW.toDouble(),
                isListItem: false,
              ),
            ),
        ],
      ),
    );
  }
}