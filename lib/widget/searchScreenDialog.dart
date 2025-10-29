import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../responce/udpSearchControllerResponce.dart';

class ScreenSearchDialog extends StatefulWidget {
  const ScreenSearchDialog({super.key});
  @override
  ScreenSearchDialogState createState() => ScreenSearchDialogState();
}

class ScreenInfo {
  final String name;
  final String ip;
  final int height;
  final int width;
  final int deviceType;
  ScreenInfo({
    required this.name,
    required this.ip,
    required this.width,
    required this.height,
    required this.deviceType,
  });
}
class ScreenInfoSingleton {
  final ValueNotifier<ScreenInfo?> _selectedScreenNotifier = ValueNotifier(null);
  static final ScreenInfoSingleton _instance = ScreenInfoSingleton._internal();

  factory ScreenInfoSingleton() => _instance;

  ScreenInfoSingleton._internal(); // 私有构造函数

  // Getter 公开变量
  ScreenInfo? get selectedScreen => _selectedScreenNotifier.value;

  // Setter 更新变量并通知监听者
  set selectedScreen(ScreenInfo? value) {
    _selectedScreenNotifier.value = value;
  }
  ValueNotifier<ScreenInfo?> get selectedScreenNotifier => _selectedScreenNotifier;
}
class ScreenSearchDialogState extends State<ScreenSearchDialog> {
  List<ScreenInfo> screenList = [];
  Set<String> addedIps = {};
  bool isSearching = false;
  RawDatagramSocket? _socket;
  Timer? _timer;
  Timer? _searchTimeoutTimer;
  ScreenInfo? _selectedScreen;

  final jsonData = {
    "protocol": {
      "name": "YQ-COM2",
      "version": "1.0",
      "remotefunction": {
        "name": "SearchController",
        "input": {
          "controllername": "",
          "screenname": "",
          "controllertype": "",
          "pid": "",
          "barcode": "",
          "width": "",
          "height": "",
          "screenrotation": "",
          "ip": "",
          "wifiipaddress": "",
          "apipaddress": "",
          "httpserverport": "",
          "subnetmask": "",
          "gateway": "",
          "wifisubnetmask": "",
          "wifigateway": "",
          "servermode": "",
          "serverport": "",
          "serverip": "",
          "cloudport": "",
          "cloudip": "",
          "jtcproxyhost": "",
          "jtcproxyport": ""
        }
      }
    }
  };

  @override
  void initState() {
    super.initState();
    startAutoSearch();
  }

  @override
  void dispose() {
    _stopBroadcast();
    super.dispose();
  }

  Future<void> _startBroadcast() async {
    try {
      // 清空之前的结果
      setState(() {
        screenList.clear();
        addedIps.clear();
        isSearching = true;
      });

      // 绑定套接字
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 10000);
      _socket!.broadcastEnabled = true;

      // 设置广播定时器
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final message = utf8.encode(jsonEncode(jsonData));
        _socket!.send(message, InternetAddress('255.255.255.255'), 10001);
        debugPrint('✅ 广播已发送');
      });

      // 设置搜索超时定时器
      _searchTimeoutTimer = Timer(const Duration(seconds: 10), () {
        _stopBroadcast();
        setState(() {
          isSearching = false;
        });
      });

      // 设置监听器
      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket!.receive();
          if (datagram != null) {
            try {
              String senderIp = datagram.address.address;
              final jsonString = String.fromCharCodes(datagram.data);
              debugPrint('收到来自 IP: $senderIp 的消息');

              final response = UdpSearchControllerResponce.fromJson(jsonDecode(jsonString));
              final output = response.remotefunction.output;

              if (output.containsKey('apipaddress') &&
                  output.containsKey('controllername') &&
                  output.containsKey('width') &&
                  output.containsKey('height')) {
                String ip = output['apipaddress'];
                if (!addedIps.contains(ip)) {
                  setState(() {
                    screenList.add(ScreenInfo(
                      name: output['controllername'],
                      ip: output['apipaddress'],
                      width: int.parse(output['width']),
                      height: int.parse(output['height']),
                      deviceType: int.parse(output['controllertype']),
                    ));
                    addedIps.add(ip);
                  });
                }
              }
            } catch (e, stack) {
              debugPrint('解析错误: $e');
              debugPrint('堆栈: $stack');
            }
          }
        }
      });

    } catch (e) {
      debugPrint('❌ 启动失败: $e');
      _stopBroadcast();
      setState(() {
        isSearching = false;
      });
    }
  }

  void _stopBroadcast() {
    _timer?.cancel();
    _timer = null;
    _searchTimeoutTimer?.cancel();
    _searchTimeoutTimer = null;
    _socket?.close();
    _socket = null;
  }

  void startAutoSearch() async {
    if (isSearching) return; // 如果正在搜索，则不重复启动

    await _startBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.wifi),
          const SizedBox(width: 10),
          const Text('屏幕列表'),
          const Spacer(),
          IconButton(
            icon: isSearching
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh),
            onPressed: isSearching ? null : startAutoSearch,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          if (isSearching && screenList.isEmpty)
            const Column(
              children: [
                SizedBox(height: 16),
                Text(
                  '正在搜索设备...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            )
          else if (!isSearching && screenList.isEmpty)
            Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  '未搜索到设备',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '请在系统WiFi配置中选择BX-或X-开头WiFi进行连接',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // 找不到屏幕怎么办的逻辑
                  },
                  child: const Text('找不到屏幕怎么办？>>', style: TextStyle(color: Colors.blue)),
                ),
              ],
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: screenList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.screen_share),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(screenList[index].name),
                            Text(screenList[index].ip),
                            Text('${screenList[index].width}*${screenList[index].height}'),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: _selectedScreen == screenList[index],
                        activeColor: Colors.green, //选中时的颜色
                        onChanged:(value){
                          setState(() {
                            if(value != null && value) {
                              _selectedScreen = screenList[index];
                            }
                            else {
                              _selectedScreen = null;
                            }
                          });
                        } ,
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          if (screenList.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = (constraints.maxWidth - 10) / 2;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          // 手动加屏逻辑
                        },
                        child: const Text('手动加屏'),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          // 确定逻辑
                          if(_selectedScreen != null) {
                            ScreenInfoSingleton().selectedScreen =
                                _selectedScreen;
                            Navigator.of(context).pop();
                          }
                          else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('请选择一个屏'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                        },
                        child: const Text('确定'),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 手动加屏逻辑
                },
                child: const Text('手动加屏'),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
          },
          child: const Text('关闭'),
        ),
      ],
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}