import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // 需要引入这个包
import 'package:crypto/crypto.dart';
// import 'package:mime/mime.dart'; // 用于获取 MIME 类型
// import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import 'dart:math';
import '../widget/searchScreenDialog.dart';
class HttpService {
  // static const String baseUrl = 'http://192.168.22.1/';

  String? _sessionId; // 存储登录成功后返回的 sessionID
  static String generatePassword(String verificationCode, String rawPassword) {
    // 第一步：计算原始密码的 SHA1
    final passwordHash = sha1.convert(utf8.encode(rawPassword)).toString();

    // 第二步：拼接验证码和密码哈希
    final combined = verificationCode + passwordHash;

    // 第三步：计算最终密码的 SHA1
    return sha1.convert(utf8.encode(combined)).toString();
  }
  // 设置 sessionId 的方法
  void setSessionId(String id) {
    _sessionId = id;
  }

  // 生成包含 stok 的完整 URL 路径
  Uri _buildStokUri(bool needSessionId) {
    final selectedScreen = ScreenInfoSingleton().selectedScreen;
    String baseUrl = "";
    if(selectedScreen != null)
      baseUrl = 'http://${selectedScreen.ip}/';
    if (!needSessionId) {
      return Uri.parse(baseUrl);
      // throw Exception('未设置 sessionId，请先登录');
    }
    return Uri.parse('$baseUrl/;stok=$_sessionId/');
  }
  Future<(String, String)> uploadFiles({
    required String fileName,
    String? uploadContent,  // 改为可选参数（文本内容）
    String? filePath,       // 新增文件路径参数
  }) async {
    if (ScreenInfoSingleton().selectedScreen == null) {
      return ("", "");
    }

    // 校验参数互斥：只能传文本内容或文件路径
    if ((uploadContent == null && filePath == null) ||
        (uploadContent != null && filePath != null)) {
      throw ArgumentError('必须且只能指定 uploadContent 或 filePath');
    }

    final url = 'http://${ScreenInfoSingleton().selectedScreen?.ip ?? ""}/upload';
    final key = fileName;
    final boundary = '----$key';
    final httpClient = HttpClient();
    final bodyBytes = BytesBuilder();

    // 添加文件部分
    final header = '''
--$boundary
Content-Disposition: form-data; name="$key"; filename="$key"
Content-Type: ${_getMimeType(filePath)}\r\n\r\n'''; // 根据文件类型设置 MIME

    bodyBytes.add(utf8.encode(header));

    // 处理文本或文件内容
    if (filePath != null) {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }
      bodyBytes.add(await file.readAsBytes());
    } else {
      bodyBytes.add(utf8.encode(uploadContent!));
    }

    bodyBytes.add(utf8.encode('\r\n--$boundary--\r\n'));

    // 发送请求（与原逻辑一致）
    final request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');
    request.contentLength = bodyBytes.length;
    request.add(bodyBytes.toBytes());

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("uploadFiles $key response $responseBody");
      return ("", key);
    } else {
      throw Exception('上传失败: ${response.statusCode}');
    }
  }

  /// 根据文件路径获取 MIME 类型
  String _getMimeType(String? filePath) {
    if (filePath == null) return 'application/octet-stream';
    final ext = path.extension(filePath).toLowerCase();
    return switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.gif' => 'image/gif',
      _ => 'application/octet-stream',
    };
  }

  Future<Map<String, dynamic>> sendRequest({
    required String remoteFunctionName,
    Map<String, dynamic>? inputParameters,
    bool needSessionId = true,
  }) async {
    try {
      final uri = _buildStokUri(needSessionId);
      final headers = {
        'Accept': 'text/json',
        'Content-Type': 'application/json;charset=UTF-8',
      };

      final requestBody = {
        'protocol': {
          'name': "YQ-COM2",
          'version': "1.0",
          'remotefunction': {
            'name': remoteFunctionName,
            if (inputParameters != null) 'input': inputParameters,
          }
        }
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('请求失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('请求异常: $e');
    }
  }
  MediaType? _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'bmp':
        return MediaType.parse('image/bmp');
      case 'jpg':
      case 'jpeg':
        return MediaType.parse('image/jpeg');
      case 'png':
        return MediaType.parse('image/png');
      default:
        return MediaType.parse('application/octet-stream');
    }
  }
}