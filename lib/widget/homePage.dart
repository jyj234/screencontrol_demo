import 'package:flutter/material.dart';
import '../base/contentItem.dart';
import '../config/textConfig.dart';
import '../types/textContent.dart';
import 'contentWidget.dart';
import 'screenPreview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double previewScreenW = 400;
  final double previewScreenH = 200;
  bool _showItemList = true;
  final ValueNotifier<List<ContentItem>> _itemsNotifier = ValueNotifier([
    // TextContent(
    //   id: "1",
    //   text: "132",
    //   zIndex: 0,
    //   position: const Offset(50, 50),
    // ),
  ]);
  final KeyboardVisibilityController _keyboardVisibility = KeyboardVisibilityController();
  ContentItem? _selectedItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _keyboardVisibility.onChange.listen((bool visible) {
      setState(() {
        _showItemList = !visible;
      });
    });

  }
  @override
  void dispose() {
    _itemsNotifier.dispose();
    super.dispose();
  }

  Widget _buildConfigPanel() {
    if (_selectedItem == null) return Container();

    switch (_selectedItem!.type) {
      case ContentType.text:
        return TextConfig(
          content: _selectedItem as TextContent,
          onChanged: (_) => setState(() {}),
          // onFocusChange: (hasFocus) {
          //   setState(() {
          //     _showItemList = !hasFocus;
          //   });
          // },
        );
      // case ContentType.image:
      //   return TextConfig(
      //     content: _selectedItem as TextContent,
      //     onChanged: (_) => setState(() {}),
      //   );
      // case ContentType.video:
      //   return TextConfig(
      //     content: _selectedItem as TextContent,
      //     onChanged: (_) => setState(() {}),
      //   );
      default:
        return Container();

    }
  }

  Widget _buildItemThumbnail(ContentItem item) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedItem?.id == item.id ? Colors.blue : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ContentWidget(
            item: item,
            isSelected: _selectedItem == item,
            onTap: () => _handleItemSelection(item),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _removeItem(item),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemContent(ContentItem item) {
    switch (item.type) {
      case ContentType.text:
        final textContent = item as TextContent;
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Text(
            textContent.text,
            style: const TextStyle(color: Colors.white),
          ),
        );
      // case ContentType.image:
      //   return Container(
      //     color: Colors.grey,
      //     alignment: Alignment.center,
      //     child: const Icon(Icons.image, color: Colors.white),
      //   );
      // case ContentType.video:
      //   return Container(
      //     color: Colors.grey,
      //     alignment: Alignment.center,
      //     child: const Icon(Icons.videocam, color: Colors.white),
      //   );
      default:
        return Container();
    }
  }

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加元素'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('文字'),
              onTap: () {
                Navigator.pop(context);
                _addTextItem();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('图片'),
              onTap: () {
                Navigator.pop(context);
                _addImageItem();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('视频'),
              onTap: () {
                Navigator.pop(context);
                _addVideoItem();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addTextItem() {
    final newItem = TextContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "新文字",
      zIndex: _itemsNotifier.value.length,
      size: Size(previewScreenW,previewScreenH)
    );
    _itemsNotifier.value = [..._itemsNotifier.value, newItem];
    setState(() {
      _selectedItem = newItem;
    });
  }

  void _addImageItem() {
    final newItem = TextContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "图片",
      zIndex: _itemsNotifier.value.length,
      position: const Offset(50, 50),
    );
    _itemsNotifier.value = [..._itemsNotifier.value, newItem];
    setState(() {
      _selectedItem = newItem;
    });
  }

  void _addVideoItem() {
    final newItem = TextContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "视频",
      zIndex: _itemsNotifier.value.length,
      position: const Offset(50, 50),
    );
    _itemsNotifier.value = [..._itemsNotifier.value, newItem];
    setState(() {
      _selectedItem = newItem;
    });
  }

  void _removeItem(ContentItem item) {
    _itemsNotifier.value = _itemsNotifier.value.where((i) => i.id != item.id).toList();
    setState(() {
      if (_selectedItem?.id == item.id) {
        _selectedItem = null;
      }
    });
  }
  void _handleItemSelection(ContentItem item) {
    setState(() {
      _selectedItem = item;
      _bringToFront(item);
    });
  }
  void _bringToFront(ContentItem item) {

    if (!_itemsNotifier.value.contains(item)) return; // 确保 item 存在

    // 计算当前最大的 zIndex
    final currentMaxZIndex = _itemsNotifier.value.fold<int>(
        0,
            (max, currentItem) => currentItem.zIndex > max ? currentItem.zIndex : max
    );

    // 更新选中 item 的 zIndex
    item.zIndex = currentMaxZIndex + 1;
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ContentItem>>(
      valueListenable: _itemsNotifier,
      builder: (context, items, _) {
        return Column(
          spacing: 10,
          children: <Widget>[
            LayoutBuilder(
            builder: (context, constraints) {
              // 更新预览屏幕宽度为可用宽度
              previewScreenW = constraints.maxWidth;
              return ScreenPreview(
                scrrenH: previewScreenH,
                scrrenW: previewScreenW, // 使用获取到的宽度
                itemsNotifier: _itemsNotifier,
                onItemSelected: (item) => _handleItemSelection(item),
                selectedItem: _selectedItem,
              );
            },
            ),
            if (_showItemList)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return GestureDetector(
                      onTap: _addNewItem,
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 40),
                      ),
                    );
                  }
                  return _buildItemThumbnail(items[index]);
                  // );
                },
              ),
            ),
            _buildConfigPanel(),
          ],
        );
      },
    );
  }
}