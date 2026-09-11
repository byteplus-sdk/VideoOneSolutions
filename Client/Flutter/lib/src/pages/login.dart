import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/service/login_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter/services.dart";
import 'package:fluttertoast/fluttertoast.dart';

const helperText = 'Username should contain least 6 characters in a-z, A-Z';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();

  String _userName = '';

  String _helperText = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏颜色
      statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色
      systemNavigationBarColor: Color.fromRGBO(255, 255, 255, 1), // 导航栏颜色
      systemNavigationBarIconBrightness: Brightness.dark, // 导航栏图标颜色
    ));
  }

  _login() async {
    final result = await loginInfo.login(_userName);
    if (result == RequestStatus.SUCCESS) {
      await Fluttertoast.showToast(
          msg: "Login success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context, true);
    } else {
      await Fluttertoast.showToast(
          msg: "Login failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _onUsernameChanged(String value) {
    // empty value
    if (value.isEmpty) {
      setState(() {
        _userName = '';
        _helperText = '';
      });
      return;
    }
    String curValue = value.trim();
    // length limit
    if (curValue.length > USERNAME_LENGTH) {
      curValue = curValue.substring(0, USERNAME_LENGTH);
      _usernameController.text = curValue;
    }
    setState(() {
      _userName = curValue;
      _helperText = isValidUsername(curValue) ? '' : helperText;
    });
  }

  static isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z]{6}$');
    return regex.hasMatch(username);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color.fromARGB(255, 29, 33, 41);
    const inputBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(201, 205, 212, 1)));
    final statusbar = MediaQuery.of(context).padding.top;

    final contentWidget = Padding(
      padding: EdgeInsets.only(left: 16.w, top: statusbar, right: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 60.w),
          Image.asset('assets/minidrama/common/loginLogo.png'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24).w,
            child: const Text(
              'Welcome to VideoOne',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0).w,
            child: const Text(
              'Username',
              style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: Color.fromARGB(255, 29, 33, 41)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12).w,
            child: TextField(
                autofocus: true,
                controller: _usernameController,
                onChanged: _onUsernameChanged,
                decoration: InputDecoration(
                  hintText: 'Please enter your username',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 134, 144, 156),
                  ),
                  helperText: _helperText,
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  disabledBorder: inputBorder,
                  focusedBorder: inputBorder,
                )),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isValidUsername(_userName) ? _login : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const Color.fromRGBO(160, 192, 255, 1);
                  }
                  return const Color.fromRGBO(22, 100, 255, 1);
                }),
                shape: WidgetStateProperty.resolveWith((states) {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  );
                }),
              ),
              child: const Text('Login',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 244, 255, 1),
                      fontSize: 16,
                      height: 24 / 16)),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
        body: Stack(
      children: [
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(231, 245, 255, 1),
                        Color.fromRGBO(253, 255, 255, 1),
                      ],
                    ),
                  ),
                ),
                const Image(
                  image: AssetImage("assets/minidrama/common/loginBg.png"),
                )
              ],
            ),
          ),
        ),
        contentWidget
      ],
    ));
  }
}
