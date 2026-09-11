import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

final logger = Logger();

const _DEV_SERVER_HOST = "rtc-sg-test.bytedance.com";
const _RELEASE_SERVER_HOST = "";
// the host of the server
const SERVER_HOST =
    String.fromEnvironment('APP_IS_RELEASE', defaultValue: _DEV_SERVER_HOST) ==
            'TRUE'
        ? _RELEASE_SERVER_HOST
        : _DEV_SERVER_HOST;
class Request {
  static Future<T> getRequest<T extends Map<String, dynamic>>(
      String path, Map<String, dynamic> param) async {
    final uri = _getUrl(path, param: param);
    final response = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as T;
      logger.d('get request for path=$path success, response=${response.body}');
      return body;
    }
    throw Exception("get request error: ${response.statusCode}");
  }

  static Future<T> postRequest<T extends Map<String, dynamic>>(
      String path, Object param) async {
    final uri = _getUrl(path);
    final response = await http.post(uri, body: json.encode(param), headers: {
      "Content-Type": "application/json",
    });
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as T;
      logger
          .d('post request for path=$path success, response=${response.body}');
      return body;
    }
    logger.d('post request for path=$path failed, response=${response.body}');
    throw Exception("post request error: ${response.statusCode}");
  }

  static Uri _getUrl(String path, {Map<String, dynamic>? param}) {
    return Uri.https(SERVER_HOST, path, param ?? {});
  }
}
