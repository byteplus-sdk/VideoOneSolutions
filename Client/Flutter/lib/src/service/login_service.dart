import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/api.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/request.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

class _LoginInfo {
  _LoginInfo();

  String? _userName;
  String? _userId;
  String? _loginToken;

  late final SharedPreferences storage;

  get userName => _userName;

  get userId => _userId;

  get loginToken => _loginToken;

  bool get isLogin =>
      _userId != null && _userName != null && _loginToken != null;

  Future<void> init() async {
    storage = await SharedPreferences.getInstance();
    final curUserId = storage.getString('userId');
    final curUserName = storage.getString('userName');
    final curAuthToken = storage.getString('loginToken');
    _userId = curUserId;
    _userName = curUserName;
    _loginToken = curAuthToken;
  }

  Future<RequestStatus> login([String? userName]) async {
    final username = userName ?? _LoginInfo.generateUserName();
    try {
      final result =
          await Request.postRequest(LOGIN_PATH, {"user_name": username});
      final response = result['response'];
      _userId = response['user_id'];
      _userName = response['user_name'];
      _loginToken = response['login_token'];
      storage.setString('userId', _userId!);
      storage.setString('userName', _userName!);
      storage.setString('loginToken', _loginToken!);
      return RequestStatus.SUCCESS;
    } catch (e) {
      // login failed
      _logger.e('login failed: $e', error: e);
      return RequestStatus.FAILED;
    }
  }

  static String generateUserName() {
    // generate a random user name
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String userName = '';
    for (int i = 0; i < USERNAME_LENGTH; i++) {
      userName += letters[Random().nextInt(letters.length)];
    }
    return userName;
  }
}

final loginInfo = _LoginInfo();
