import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/feed_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:byteplus_vod/ve_vod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/player_controller.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/vertical_page/vertical_video_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

// ignore: must_be_immutable
class FeedView extends StatefulWidget {
  FeedView({super.key, required this.active});

  bool active;

  static const routeName = '/feed';

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> with WidgetsBindingObserver {
  late FeedService _feedService;

  LoadStatus _loadStatus = LoadStatus.LOADING;

  late final TTVideoPlayerView playerView;

  late final VodPlayerFlutter player;

  late bool _loadingMore = false;

  final PageController _pageController = PageController();

  final PlayerController _playerController = PlayerController();
  bool _networkInterrupt = false;

  AppLifecycleListener? _lifecycleListener;


  @override
  void didUpdateWidget(covariant FeedView oldWidget) {
    final currentPlaybackController =
        _playerController.getCurrentVideoController();
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        currentPlaybackController?.play();
      } else {
        currentPlaybackController?.pause();
      }
    }
  }
  

  @override
  void initState() {
    super.initState();

    initAppLifecycleListener();

    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    _feedService = FeedService();
    _initFeedData();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        Fluttertoast.showToast(
          msg: 'network interrupt',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        _logger.i('[feed page]: network interrupt');
      } else {
        if (_networkInterrupt) {
          Fluttertoast.showToast(
            msg: 'network resumed',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        _networkInterrupt = false;
      }
      setState(() {});
    });
  }

  initAppLifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        changePlayerState(false);
      },
      onInactive: () {
       changePlayerState(true);
      },
      onHide: () {
        changePlayerState(true);
      },
      onShow: () {
        changePlayerState(false);
      },
      onDetach: () {
        changePlayerState(true);
      });
  }

  changePlayerState(isNeedPause){
    final currentPlaybackController =
        _playerController.getCurrentVideoController();
    if(isNeedPause){
      currentPlaybackController?.pause();
    }else{
      if(ModalRoute.of(context)!.isCurrent){
         currentPlaybackController?.play();
      }else{
        currentPlaybackController?.pause();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _lifecycleListener?.dispose();
    _feedService.dispose();
    _playerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
  }

  _initFeedData() async {
    final res = await _feedService.loadFeed();
    if (res == RequestStatus.SUCCESS) {
      _loadStatus = LoadStatus.SUCCESS;
      _playerController.dispose();
      final feedList = _feedService.getFeedList();
      _playerController.addVideos(feedList);
    } else {
      _loadStatus = LoadStatus.FAILED;
    }
    setState(() {});
  }

  Future<void> _handleRefresh() async {
    _feedService.dispose();
    final res = await _feedService.loadFeed();
    if (res == RequestStatus.SUCCESS) {
      _playerController.dispose();
      final feedList = _feedService.getFeedList();
      _playerController.addVideos(feedList);
    } else {
      Fluttertoast.showToast(
        msg: 'Load Failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    setState(() {});
  }

  scrollBottomHandler() async {
    if ((_pageController.page ?? 0).truncate() != _feedService.feedCount - 1 ||
        _feedService.feedCount <= 1) {
      return;
    }
    loadMore(showLoading: true);
  }

  loadMore({showLoading = false}) async {
    if (_loadingMore || !_feedService.hasMore) {
      return;
    }
    _loadingMore = true;
    if (showLoading) {
      setState(() {});
    }
    final res = await _feedService.loadFeed();
    if (res == RequestStatus.SUCCESS) {
      _loadingMore = false;
      final feedList = _feedService.getFeedList();
      _playerController.addVideos(feedList);
    } else {
      Fluttertoast.showToast(
        msg: 'Load Failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      _loadingMore = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    Widget? feed;
    if (_loadStatus == LoadStatus.LOADING) {
      body = const Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (_loadStatus == LoadStatus.FAILED) {
      body = const Placeholder(
        child: Center(
          child: Text('Load Failed'),
        ),
      );
    }

    if(body != null){
      return body;
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is OverscrollNotification) {
                scrollBottomHandler();
              }
              return true;
            },
            child: RefreshIndicator.adaptive(
              onRefresh: _handleRefresh,
              child: Stack(children: [
                PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _playerController.videoCount,
                    controller: _pageController,
                    onPageChanged: _pageChange,
                    itemBuilder: (context, idx) {
                      final controller =
                          _playerController.getVideoControllerByIndex(idx);
                      if (idx == 0 && controller!.didStartToPlay == false) {
                        _playerController.setCurVideoVidByIndex(idx);
                        controller.play();
                      } else {
                        controller!.init();
                      }
                      return VerticalVideoPage(videoController: controller);
                    }),
                if (_loadingMore)
                  const Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ]),
            ),
          ),
        );    
        },
  );



        
  }

  void _pageChange(int idx) {
    _playerController.pauseCurrentVideo();
    _playerController.setCurVideoVidByIndex(idx);
    final controller = _playerController.getVideoControllerByIndex(idx);
    controller!.play();
    if (_feedService.hasMore && idx > _playerController.videoCount - 3) {
      loadMore();
    }
  }
}
