import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screencontrol_demo/types/picContent.dart';
import 'package:screencontrol_demo/widget/searchScreenDialog.dart';
import '../base/contentItem.dart';
import '../config/picConfig.dart';
import '../config/textConfig.dart';
import '../config/videoConfig.dart';
import '../service/httpService.dart';
import '../types/textContent.dart';
import '../types/videoContent.dart';
import '../xmlFileGenerator/modelDefine.dart';
import '../xmlFileGenerator/program.dart';
import '../xmlFileGenerator/programsList.dart';
import 'contentWidget.dart';
import 'screenPreview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart'; // ✅ 正确导入
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int previewScreenW = 400;
  final int previewScreenH = 200;
  bool _showItemList = true;
  final service = HttpService();
  final thumbnailSize = 80.0;
  final ValueNotifier<List<CommonPanel>> _itemsNotifier = ValueNotifier([
    // TextContent(
    //   id: "1",
    //   text: "132",
    //   zIndex: 0,
    //   position: const Offset(50, 50),
    // ),
  ]);
  final KeyboardVisibilityController _keyboardVisibility = KeyboardVisibilityController();
  CommonPanel? _selectedItem;

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

    return  SingleChildScrollView( // 添加可滚动区域
          padding: const EdgeInsets.all(8.0),
            child: _selectedItem == null
                ? const SizedBox.shrink() // 空值兜底
                : switch (_selectedItem!.panelType) {
              PanelType.text => TextConfig(
                content: _selectedItem! as TextPanel,
                onChanged: (_) => setState(() {}),
              ),
              PanelType.pic => PicConfig( // 其他类型示例
                content: _selectedItem! as PicturePanel,
                onChanged: (_) => setState(() {}),
              ),
              PanelType.video => VideoConfig( // 其他类型示例
                content: _selectedItem! as VideoPanel,
                onChanged: (_) => setState(() {}),
              ),
              _ => const Text('未支持的类型'), // 默认兜底
            },
    );
  }

  Widget _buildItemThumbnail(CommonPanel item) {
    return Stack(
      children: [
        Container(
          width: thumbnailSize,
          height: thumbnailSize,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: _selectedItem == item ? Colors.blue : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CarouselContentWidget(
            item: item,
            isSelected: _selectedItem == item,
            onTap: () => _handleItemSelection(item),
            screenPreviewW: thumbnailSize,
            screenPreviewH: thumbnailSize,
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
// 定义变量保存选择的图片
  File? _selectedImage;

  Future<void> _addImageItem() async {
    final newItem = PicturePanel(
    );
    _itemsNotifier.value = [..._itemsNotifier.value, newItem];
    setState(() {
      _selectedItem = newItem;
    });
  }
  _addTextItem() {
    TextUnit textUnit = TextUnit(content: "新文字");
    final newItem = TextPanel(
      textUnit: textUnit,
    );
    _itemsNotifier.value = [..._itemsNotifier.value, newItem];
    setState(() {
      _selectedItem = newItem;
    });
  }


  void _addVideoItem() {
    final newItem = VideoPanel(
    );
    _itemsNotifier.value = [..._itemsNotifier.value, newItem];
    setState(() {
      _selectedItem = newItem;
    });
  }

  void _removeItem(CommonPanel item) {
    _itemsNotifier.value = _itemsNotifier.value.where((i) => i != item).toList();
    setState(() {
      if (_selectedItem == item) {
        _selectedItem = null;
      }
    });
  }
  void _handleItemSelection(CommonPanel item) {
    setState(() {
      _selectedItem = item;
      _bringToFront(item);
    });
  }
  void _bringToFront(CommonPanel item) {

    if (!_itemsNotifier.value.contains(item)) return; // 确保 item 存在

    // 计算当前最大的 zIndex
    final currentMaxZIndex = _itemsNotifier.value.fold<int>(
        0,
            (max, currentItem) => currentItem.zOrder > max ? currentItem.zOrder : max
    );

    // 更新选中 item 的 zIndex
    item.zOrder = currentMaxZIndex + 1;
  }
  Future<void> _login() async{
    try {
      // 第一步：获取验证码
      final verificationResponse = await service.sendRequest(
          remoteFunctionName: "getVerificationCode",
          inputParameters:{"username":"guest"},
          needSessionId: false,
      );
      final verificationCode = verificationResponse['remotefunction']['output']['verificationcode'];
      print('验证码获取成功: $verificationCode');
      // 第二步：生成密码
      final password = HttpService.generatePassword(verificationCode, 'guest');
      print('生成密码: $password');
      // 第三步：用户登录
      final loginResponse = await service.sendRequest(
        remoteFunctionName: "userLogin",
        inputParameters: {
          "username": "guest",
          "verificationcode": verificationCode,
          "password": password,
        },
        needSessionId: false,
      );

      print('收到回复: $loginResponse');
      // 获取会话 ID
      final sessionId = loginResponse['remotefunction']['output']['sessionID'];
      print('登录成功，Session ID: $sessionId');
      service.setSessionId(sessionId);
    } catch (e) {
      print('操作失败: $e');
    }
  }
  String generateFileName([String? filePath]) {
    final uuid = Uuid();
    // 从文件路径中提取带后缀
      String suffix = "";
      if(filePath != null){
        suffix = path.extension(filePath);
      }
      else {
        suffix = ".xml";
      }

    // 计算可用 UUID 长度
    final maxUuidLength = 32 - suffix.length;

    // 处理后缀过长的情况
    if (maxUuidLength < 0) {
      throw ArgumentError('文件后缀长度超过32字符');
    }

    // 生成并处理 UUID
    final fullUuid = uuid.v4().replaceAll('-', '');
    final uuidPart = fullUuid.substring(0, maxUuidLength.clamp(0, 32));

    return uuidPart + suffix;
  }
  void sendPrograms() async {
    if(ScreenInfoSingleton().selectedScreen == null) {
      return;
    }
    await _login();
    var enableUploadDownloadResponse = await service.sendRequest(
        remoteFunctionName: "enableUploadDownload",
        inputParameters:{
          "type": "upload",
          "flag": "on"
        }
    );
    print("enableUploadDownloadResponse $enableUploadDownloadResponse");
    final enableDownloadResponse = await service.sendRequest(
        remoteFunctionName: "enableUploadDownload",
        inputParameters:{
          "type": "download",
          "flag": "on"
        }
    );
    var clearUselessMaterialResponse = await service.sendRequest(
        remoteFunctionName: "clearUselessMaterial",
    );
    print("clearUselessMaterialResponse $clearUselessMaterialResponse");
    List<TextPanel> textPanels = [];
    List<PicturePanel> picPanels = [];
    List<VideoPanel> videoPanels = [];
    for(int i = 0;i < _itemsNotifier.value.length;i++) {
      final item = _itemsNotifier.value[i];
      // item.width = (item.width * ScreenInfoSingleton().selectedScreen!.width).toInt();
      // item.height = textItem.height * ScreenInfoSingleton().selectedScreen!.height).toInt();

      if(item.panelType == PanelType.text) {
        final textPanel = item as TextPanel;
        textPanel.zOrder = i;
        textPanels.add(textPanel);
        // final textItem = item as TextContent;
        // final textUnits = [TextUnit(
        //   content: textItem.text,
        // )];
        // TextPanel textPanel = TextPanel(x: textItem.x, y: textItem.y,
        //                                 width: (textItem.width * ScreenInfoSingleton().selectedScreen!.width).toInt(),
        //                                 height: (textItem.height * ScreenInfoSingleton().selectedScreen!.height).toInt(),
        //                                 unitType: UnitType.text,textUnits: textUnits,zOrder: i);
        // textPanels.add(textPanel);
      }
      else if(item.panelType == PanelType.pic){
        // final picPanel = item as PicturePanel;
        final picPanel = item as PicturePanel;
        picPanel.zOrder = i;
        // final picItem = item as PicturePanel;
        // List<PicUnit> picUnits = [];
        for(int j = 0;j < picPanel.picUnits.length;j++){
          final picUnit = picPanel.picUnits[j];
          final fileName = generateFileName(picUnit.filePath);
          await service.uploadFiles(fileName: fileName,filePath: picUnit.filePath );
          await service.sendRequest(
              remoteFunctionName: "moveFile",
              inputParameters:{
                "src": fileName,
                "dst": "share/$fileName",
              }
          );
          picUnit.uploadFilePath = "share/$fileName";
          picUnit.order = j;
          // picUnits.add(PicUnit(filePath: "share/$fileName",order: j));
        }
        picPanels.add(picPanel);

        // PicturePanel picPanel = PicturePanel(x: picItem.x, y: picItem.y,
        //     width: (picItem.width * ScreenInfoSingleton().selectedScreen!.width).toInt(),
        //     height: (picItem.height * ScreenInfoSingleton().selectedScreen!.height).toInt(),
        //     picUnits: picUnits,zOrder: i);
        // picPanels.add(picPanel);
      }
      else if(item.panelType == PanelType.video){
        final videoPanel = item as VideoPanel;

        for(int j = 0;j < videoPanel.videoUnits.length;j++) {
          final videoUnit = videoPanel.videoUnits[j];
          try {
            final outputPath = await convertVideoToH264(videoUnit.file);
            print('转码完成，输出文件：$outputPath');
            final fileName = generateFileName(outputPath);
            await service.uploadFiles(
                fileName: fileName, filePath: outputPath);
            await service.sendRequest(
                remoteFunctionName: "moveFile",
                inputParameters: {
                  "src": fileName,
                  "dst": "share/$fileName",
                }
            );
            videoUnit.file =  "share/$fileName";
            videoUnit.order = j;
            // videoUnits.add(VideoUnit(file: "share/$fileName",order: j));
            // VideoPanel videoPanel = VideoPanel(
            //     x: videoItem.x,
            //     y: videoItem.y,
            //     width: (videoItem.width *
            //         ScreenInfoSingleton().selectedScreen!.width).toInt(),
            //     height: (videoItem.height *
            //         ScreenInfoSingleton().selectedScreen!.height).toInt(),
            //     videoUnits: videoUnits,
            //     zOrder: i);
            // videoPanels.add(videoPanel);
            // 更新UI或其他后续操作
          } catch (e) {
            print('转码出错：$e');
            // 处理错误
          }
        }
        videoPanel.zOrder = i;
        videoPanels.add(videoPanel);
      }
    }
    String programName = generateFileName();
    final programXml = generateProgramXml(
        programName: programName,
        textPanels:textPanels,
        picturePanels: picPanels,
        videoPanels: videoPanels,
    );
    print("programXml $programXml");
    await service.uploadFiles(fileName: programName, uploadContent: programXml);
    Map<String, dynamic> copyFileResponse = await service.sendRequest(
        remoteFunctionName: "moveFile",
        inputParameters:{
          "src": "$programName",
          "dst": "programs/$programName",
        }
    );
    print('copyFileResponse: $copyFileResponse');

    List<ProgramInfo> programs = [];
    programs.add(ProgramInfo(programFile: programName));
    final programsListXml = generatePlaylistXml(programs: programs);
    programName = generateFileName();
    print("programsListXml $programsListXml");

    await service.uploadFiles(fileName: programName, uploadContent: programsListXml);
    copyFileResponse = await service.sendRequest(
        remoteFunctionName: "moveFile",
        inputParameters:{
          "src": "$programName",
          "dst": "lists/$programName",
        }
    );
    print('copyFileResponse: $copyFileResponse');
    final playResponse = await service.sendRequest(
      remoteFunctionName: "play",
      inputParameters: {
        "type": "program",
        "playlist": "lists/$programName",
      },
    );
    print('playResponse: $playResponse');
    enableUploadDownloadResponse = await service.sendRequest(
        remoteFunctionName: "enableUploadDownload",
        inputParameters:{
          "type": "upload",
          "flag": "off"
        }
    );
    final verificationResponse = await service.sendRequest(
      remoteFunctionName: "userLogout",
      inputParameters:{"username":"guest"},
    );
    print('verificationResponse: $verificationResponse');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发送成功！'),
        duration: Duration(seconds: 2), // 自动消失时间
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CommonPanel>>(
      valueListenable: _itemsNotifier,
      builder: (context, items, _) {
        return Column(
          children: <Widget>[
              LayoutBuilder(
                builder: (context, constraints) {
                  // 更新预览屏幕宽度为可用宽度
                  previewScreenW = constraints.maxWidth.toInt();
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
              // width: 300,
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
            // Expanded(
            //   child: Container(
            //   color: Colors.blue,
            //   child: Center(child: Text("Expanded 填满剩余空间")),
            // )),
            Expanded(child: _buildConfigPanel(),
            ),
          LayoutBuilder( // 使用LayoutBuilder获取可用宽度
                  builder: (context, constraints) {
                    final buttonWidth = (constraints.maxWidth - 10) / 2;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(context: context,
                                builder:  (BuildContext context) => ScreenSearchDialog(),
                            );
                          },
                          child: const Text('寻机'),
                          ),
                        ),
                        ValueListenableBuilder<ScreenInfo?>(
                          valueListenable: ScreenInfoSingleton().selectedScreenNotifier,
                          builder: (context, selectedScreen, child) {
                            return
                            SizedBox(
                              width: buttonWidth,
                              child: ElevatedButton(
                              onPressed: selectedScreen == null
                                  ? null  // 如果 selectedScreen 为 null，按钮禁用
                                  : () => sendPrograms(),  // 否则调用 sendPrograms()
                              child: const Text('发送'),
                            ),
                            );
                          },
                        )
                      ],
                    );
                  },
          ),
          ],
        );
      },
    );
  }
}