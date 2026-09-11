import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_channel/drama_list.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/pages/feed.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/player_controller.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/common/keep_alive_wrapper.dart';
import 'package:flutter/services.dart';

class DramaChannelView extends StatefulWidget {
  const DramaChannelView({super.key});

  static const routeName = '/drama_channel';

  @override
  State<DramaChannelView> createState() => _DramaChannelViewState();
}

const tabs = [
  {
    'title': 'Home',
  },
  {
    'title': 'Channel',
  }
];

class _DramaChannelViewState extends State<DramaChannelView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final PlayerController _playerController = PlayerController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      _curIndex = _tabController.index;
      setState(() {});
    });
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  int _curIndex = 0;

  updateSelectedIndex(int index) {
    final videoController = _playerController.getCurrentVideoController();
    if (index != 1 && videoController != null) {
      videoController.pause();
    }
    _curIndex = index;
    _tabController.index = index;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white, 
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const KeepAliveWrapper(
                          keepAlive: true, child: DramaList()),
                      KeepAliveWrapper(
                        keepAlive: true,
                        child: FeedView(
                          active: _curIndex == 1,
                        ),
                      )
                    ]),
                Positioned(
                    top: padding.top + 5.w,
                    left: 8.w,
                    child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }))
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: _curIndex == 0
                      ? Image.asset('assets/minidrama/common/homeSelect.png')
                      : Image.asset('assets/minidrama/common/home.png'),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                    icon: _curIndex == 1
                        ? Image.asset('assets/minidrama/common/feedSelect.png')
                        : Image.asset('assets/minidrama/common/feed.png'),
                    label: "For you")
              ],
              onTap: updateSelectedIndex,
              currentIndex: _curIndex,
            )));
  }
}
