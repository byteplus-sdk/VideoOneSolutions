import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_item_meta.dart';
import 'package:byteplus_vod/ve_vod.dart';
import 'dart:io';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/log/logger.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/utils.dart';
import 'package:logger/logger.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';
// import 'package:flutter/foundation.dart';


// 移除 const 关键字，因为 LoggerUtil() 不是常量构造函数
final _logger = LoggerUtil();

class PlayerController {
  final List<DramaItem> videoList = [];

  // 存储一份数据的冗余，方便快速查找，直接查找VideoController, 开销会比较大
  final Map<String, DramaItem> videoMetaMap = {};
  // videoController 列表
  final Map<String, VideoController> videoControllers = {};
  // 视频总数
  get videoCount => videoList.length;
  // vip视频meta列表
  get vipVideos =>
      videoList.where((video) => video.videoMeta.vip == true).toList();
  // 当前播放视频的索引
  String? _curVideoVid;

  VideoController? getCurrentVideoController() {
    if (_curVideoVid == null) {
      return null;
    }
    return getVideoControllerByVid(_curVideoVid!);
  }

  pauseCurrentVideo() {
    final controller = getCurrentVideoController();
    if (controller!= null) {
      controller.pause();
    }
  }

  // 设置当前播放的视频
  void setCurVideoVidByIndex(int index) {
    _curVideoVid = videoList[index].videoMeta.vid;
  }

  // 根据索引查找VideoController
  VideoController? getVideoControllerByIndex(int index) {
    return videoControllers[videoList[index].videoMeta.vid!];
  }

  // 根据vid查找VideoController
  VideoController? getVideoControllerByVid(String vid) {
    return videoControllers[vid];
  }

  // 添加视频
  void addVideos(List<DramaItem> videos) {
    final uniqVideos = videos
        .where((video) => !videoControllers.containsKey(video.videoMeta.vid));
    videoList.addAll(uniqVideos);
    List<TTVideoEngineMediaSource> sourceList = [];
    List<TTVideoEngineVidSource> vidSourceList = [];
    for (var video in uniqVideos) {
      final videoMeta = video.videoMeta;
      videoMetaMap[videoMeta.vid!] = video;
      final source = videoMeta.vip == false
          ? TTVideoEngineVidSource.init(
              vid: videoMeta.vid,
              playAuthToken: videoMeta.playAuthToken,
              resolution:
                  TTVideoEngineResolutionType.TTVideoEngineResolutionTypeHD)
          : null;
      videoControllers[videoMeta.vid!] = VideoController(
          videoMeta: videoMeta, dramaMeta: video.dramaMeta, source: source);
          
      if (source != null) {
        sourceList.add(source);
        vidSourceList.add(source);
      }
    }

    // _customPreload(vidSourceList);
    _addStrategy(sourceList);
  }

  // 如果视频列表中有vip视频，解锁后，更新vip视频列表
  void updateVideo(List<DramaItem> videos) {
    List<TTVideoEngineMediaSource> sourceList = [];
    List<TTVideoEngineVidSource> vidSourceList = [];
    for (var video in videos) {
      final vid = video.videoMeta.vid; // 视频的vid
      videoMetaMap[vid!] = video;
      final videoMeta = video.videoMeta;
      if (videoControllers.containsKey(vid)) {
        final controller = videoControllers[vid];
        if (controller!.isVip && videoMeta.vip == false) {
          controller.videoMeta = videoMeta;
          final source = TTVideoEngineVidSource.init(
              vid: videoMeta.vid,
              playAuthToken: videoMeta.playAuthToken,
              resolution:
                  TTVideoEngineResolutionType.TTVideoEngineResolutionTypeHD);
          sourceList.add(source);
          vidSourceList.add(source);
          controller.source = source;
        }
      }
    }

    // _customPreload(vidSourceList);
    _updateStrategy(sourceList);
  }

  void clearVideos() {
    _curVideoVid = null;
    videoList.clear();
    videoMetaMap.clear();
    for (var v in videoControllers.values) {
      v.dispose();
    }
    videoControllers.clear();
  }

  void _addStrategy(List<TTVideoEngineMediaSource> sourceList) {
    if (GlobalSdkConfiguration.enableStrategyPreload) {
      TTVideoEngineStrategy.setStrategyVideoSources(videoSources: sourceList);
    }
  }

  void _customPreload(List<TTVideoEngineVidSource> sourceList) {
    for (var source in sourceList) {
      TTVideoEnginePreloaderVidItem item = TTVideoEnginePreloaderVidItem.vidItemWithVideoSource(source, 800 * 1024);
      TTVideoEnginePreload.addTaskWithVidItem(item);
    }
  }

  void _updateStrategy(List<TTVideoEngineMediaSource> sourceList) {
    if (GlobalSdkConfiguration.enableStrategyPreload) {
      TTVideoEngineStrategy.addStrategyVideoSources(videoSources: sourceList);
    }
  }

  void dispose() {
    final curVideoController = getCurrentVideoController();
    if (curVideoController != null) {
      if (curVideoController.getPlayStatus() ==
          TTVideoEnginePlaybackState.playing) {
        curVideoController.pause();
      }
    }
    clearVideos();
  }


  static Future<void> initTTSDK() async {
    // Enable logging
    if(OPEN_DEBUG_LOG){
      FlutterTTSDKManager.openAllLog();
    }
    
    // Register plugin logs
    TTFLogger.onLog = (logLevel, msg) {
      _logger.d(msg);
    };

    // For Android, provide a valid channel ID for statistics; for iOS, it is optional and defaults to App Store
    String channel = Platform.isAndroid ? ANDROID_CHANNEL : IOS_CHANNEL;
    // Initialize VOD configuration
    TTSDKVodConfiguration vodConfig = TTSDKVodConfiguration();
    // Set the maximum cache size, default is 100M, adjust according to your own business scenario, cache eviction is performed based on LRU rules when the cache size exceeds the maximum size
    vodConfig.cacheMaxSize = CACHE_MAX_SIZE;

    // Provide the AppID obtained from the BytePlus VOD console
    TTSDKConfiguration sdkConfig =
        TTSDKConfiguration.defaultConfigurationWithAppIDAndLicPath(
            appID: APP_ID, licenseFilePath: LICENSE_PATH, channel: channel);
    sdkConfig.vodConfiguration = vodConfig;
    FlutterTTSDKManager.startWithConfiguration(sdkConfig);
    final deviceId = await getId();
    // Set the unique ID after SDK initialization, which is used for single tracking and troubleshooting, usually the user ID or device ID
    FlutterTTSDKManager.setCurrentUserUniqueID(deviceId);

    // Enable premium features
    enablePremiumFeature();
  }

  static enablePremiumFeature() {
    if(GlobalSdkConfiguration.enableStrategyPreload && GlobalSdkConfiguration.enableStrategyPreRender){
      TTVideoEngineStrategy.enableEngineStrategy(
          strategyType: TTVideoEngineStrategyType.preloadAndPreRender,
          scene: TTVideoEngineStrategyScene.smallVideo);
    }else if(GlobalSdkConfiguration.enableStrategyPreload){
      _logger.d('开启预加载');
      TTVideoEngineStrategy.enableEngineStrategy(
          strategyType: TTVideoEngineStrategyType.preload,
          scene: TTVideoEngineStrategyScene.smallVideo);
    }else if(GlobalSdkConfiguration.enableStrategyPreRender){
      TTVideoEngineStrategy.enableEngineStrategy(
          strategyType: TTVideoEngineStrategyType.preRender,
          scene: TTVideoEngineStrategyScene.smallVideo);
    }else{
      TTVideoEngineStrategy.clearAllEngineStrategy();
    }
  }
}
