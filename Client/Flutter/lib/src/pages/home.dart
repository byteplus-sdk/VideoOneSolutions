import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vod_flutter_mini_drama/src/widgets/home_card.dart';
import "package:flutter/services.dart";
import 'package:vod_flutter_mini_drama/src/constants/home.dart';

/// Displays detailed information about a SampleItem.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏颜色
      statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色
      systemNavigationBarColor: Color.fromRGBO(255, 255, 255, 1), // 导航栏颜色
      systemNavigationBarIconBrightness: Brightness.dark, // 导航栏图标颜色
    ));
    // if (!loginInfo.isLogin) {
    //   _doLogin();
    // }
  }

  _doLogin() async {
    // wait for render finish
    await Future.delayed(Duration.zero);
    final result = await Navigator.pushNamed(context, "/login");
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final topSize = MediaQuery.of(context).padding.top;
    // if (!loginInfo.isLogin) {
    //   return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    // }

    final body = _selectedIndex == 0
        ? Container(
            padding: EdgeInsets.only(top: topSize, left: 16.w, right: 16.w),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/home/bg.png',
                  ),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 15).w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 57.w,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/home/logo.png',
                                width: 72.w, height: 13.w),
                            Padding(
                              padding: const EdgeInsets.only(top: 8).w,
                              child: const Text("VideoOne Center",
                                  style: TextStyle(
                                      fontSize: 28,
                                      height: 36 / 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(255, 255, 255, 1))),
                            )
                          ]),
                    ),
                    ClipOval(
                      child: Image(
                          image: const AssetImage(
                            'assets/minidrama/avatars/avatar00.png',
                          ),
                          height: 30.w,
                          width: 30.w),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 20).w,
                child: const Text(
                  "Welcome to the VideoOne Demo Center! Please select the scene of interest.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    for (var item in HOME_POSTER_CONFIG)
                      HomeCard(
                          imgPath: item["imgPath"]!,
                          title: item['title']!,
                          subTitle: item["subTitle"]!,
                          linkRoute: item["linkRoute"])
                  ],
                ),
              )
            ]),
          )
        : const Placeholder(child: Center(child: Text("Stay tuned...")));
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Scene"),
            BottomNavigationBarItem(
                icon: Icon(Icons.code_outlined), label: "Function")
          ],
          onTap: updateSelectedIndex,
          currentIndex: _selectedIndex,
        ),
        body: body);
  }
}
