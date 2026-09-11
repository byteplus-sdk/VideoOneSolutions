import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'package:byteplus_vod/ve_vod.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/video_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';

Logger _logger = Logger();

class VideoController extends ChangeNotifier {
  // video config
  late VideoMeta videoMeta;

  late DramaMeta? dramaMeta;

  late TTVideoEngineVidSource? source;
  // video player
  late final VodPlayerFlutter _player;
  // player view for the video
  TTVideoPlayerView? _playerView;
  // viewId for the player view
  late final int _viewId;

  late List<TTVideoEngineResolutionType> resTypes = [];

  TTVideoEngineResolutionType resolution =
      TTVideoEngineResolutionType.TTVideoEngineResolutionTypeSD;

  bool _didStartToPlay = false;

  bool _didVideoReady = false;


  get didStartToPlay => _didStartToPlay;

  bool get didVideoReady => _didVideoReady;

  bool _initinalized = false;

  bool get isVertical => videoMeta.height! > videoMeta.width!;

  Timer? _timer;

  Duration position = Duration.zero;

  Duration positionDuration = Duration.zero;

  PlaySpeed speed = PlaySpeed.NORMAL;

  late final Future<int> _playViewFuture;

  TTVideoEnginePlaybackState? _playStatus;

  TTVideoEngineLoadState? _loadStatus;

  VideoController(
      {required this.videoMeta, required this.dramaMeta, this.source});

  get isVip => videoMeta.vip == true;

  TTVideoEnginePlaybackState? getPlayStatus() {
    return _playStatus;
  }

  TTVideoEngineLoadState? getLoadStatus() {
    return _loadStatus;
  }

  TTVideoPlayerView getPlayView() {
    if (_playerView != null) {
      return _playerView!;
    }
    final Completer<int> playCompleter = Completer<int>();
    _playViewFuture = playCompleter.future;
    return _playerView ??= TTVideoPlayerView(
        onPlatformViewCreated: (int viewId) {
          // After the NativeView is created, the player and viewId need to be bound
          _viewId = viewId;
          playCompleter.complete(viewId);
        },
        nativeViewType: NativeViewType.TextureView);
  }

  Future<void> init() async {
    if (_initinalized) {
      return;
    }
    _initinalized = true;
    _player = VodPlayerFlutter();

    _player.playbackStateDidChanged = _playbackStateDidChanged;
    _player.loadStateDidChanged = _loadStateDidChanged;
    _player.didFinish = _didFinish;
    _player.readyToDisplay = _readyToDisplay;
    _player.fetchedVideoModel = _fetchedVideoModel;

    getPlayView();
    await _playViewFuture;
    await _player.createPlayer();
    _player.setPlayerContainerView(_viewId);
  }

  Future<void> startToPlay() async {
    try {
      await init();
      if (source == null) {
        return;
      }
      _didStartToPlay = true;
      notifyListeners();
      _player.setMediaSource(source!);
      _player.setHardwareDecode(GlobalSdkConfiguration.isHardwareDecode);
      _player.setTrackVolumeEnabled(GlobalSdkConfiguration.isTrackVolume);

      setScalingMode(!isVertical
          ? TTVideoEngineScalingMode.TTVideoEngineScalingModeAspectFit
          : TTVideoEngineScalingMode.TTVideoEngineScalingModeAspectFill);
      _player.setClipToBounds(GlobalSdkConfiguration.isClip);

      openTextureRender(!GlobalSdkConfiguration.closeTextureRender);
      setLooping(true);
      _player.setSubtitleEnabled(true);
      _player.setSubtitleShow(true);
      play();
    } catch (e) {
      _didStartToPlay = false;
      _logger.e('startToPlay error: $e');
    }
  }

  Future<void> play() async {
    try {
      if(source == null) {
      return;
    }

    if (!_didStartToPlay) {
      startToPlay();
      return;
    }
    if (Platform.isAndroid) {
      _player.forceDraw();
    }
    if (_playStatus == TTVideoEnginePlaybackState.playing) {
      return;
    }
    if (_didVideoReady) {
      _startTrackPlayInfo();
    }
    _player.play();
    }catch(e) {
      print(e); 
    }
  }

  pause() {
    try{
      if(source == null) {
      return;
      }
      if (_didVideoReady) {
        _stopTrackPlayInfo();
      }
      _player.pause();
    }catch(e) {
      print(e);
    }
  }

  _startTrackPlayInfo() {
    _stopTrackPlayInfo();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      final [curPosition, playableDuration] = await Future.wait([
        getPosition(),
        getPlayableDuration(),
      ]);
      position = curPosition;
      positionDuration = playableDuration;
      notifyListeners();
    });
  }

  _stopTrackPlayInfo() {
    _timer?.cancel();
  }

  void setDramaMeta(DramaMeta? meta) {}

  void close() {
    _stopTrackPlayInfo();
    _player.stop();
    _player.closeAsync();
  }

  Future<void> seekToTimeMs(double time) async {
    position = Duration(milliseconds: time.round());
    notifyListeners();
    return await _player.seekToTimeMs(time: time);
  }

  Future<Duration> getPosition() async {
    return await _player.position;
  }

  Future<Duration> getPlayableDuration() async {
    return await _player.playableDuration;
  }

  Future<Duration> getCurrentPlaybackTime() async {
    return await _player.position;
  }

  Future<TTVideoEnginePlaybackState> getPlaybackState() async {
    return await _player.getPlaybackState();
  }

  Future<TTVideoEngineResolutionType> getCurrentResolution() async {
    return await _player.currentResolution;
  }

  Future<void> setCurrentResolution(
      TTVideoEngineResolutionType newResolution) async {
    await _player.configResolutionAfterStart(targetResolution: newResolution);
    resolution = newResolution;
    notifyListeners();
  }

  Future<void> setStartTimeMs(double time) async {
    return await _player.setStartTimeMs(time);
  }

  Future<void> setRadioMode(bool radioMode) async {
    await _player.setRadioMode(radioMode);
  }

  Future<void> setScalingMode(TTVideoEngineScalingMode mode) async {
    await _player.setScalingMode(mode);
  }

  Future<void> openTextureRender(bool open) async {
    await _player.openTextureRender(open);
  }

  Future<void> setLooping(bool looping) async {
    await _player.setLooping(looping);
  }

  Future<void> setPlaybackSpeed(PlaySpeed newSpeed) async {
    speed = newSpeed;
    notifyListeners();
    await _player.setPlaybackSpeed(speed.speed);
  }

  void forceDraw() {
    _player.forceDraw();
  }

  String calculateMD5(String input) {
    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  void setCustomHeader(String key, String value) async {
    await _player.setCustomHeader(key, value);
  }

  void _playbackStateDidChanged(TTVideoEnginePlaybackState state) {
    _playStatus = state;
    notifyListeners();
    _logger.i('playbackStateDidChanged: $state');
  }

  void _loadStateDidChanged(
      TTVideoEngineLoadState loadState, Map<Object?, Object?>? extraInfo) {
    _logger.i(
        "TTF --- - loadStateDidChanged:  $loadState, extra: $extraInfo, hashCode: ${_player.hashCode}");
    _loadStatus = loadState;
    notifyListeners();
  }

  void _didFinish(TTError? error) {
    _logger
        .i("TTF --- - didFinish, hashCode: ${_player.hashCode} error: $error");
  }

  void _readyToDisplay() {
    _didVideoReady = true;
    _startTrackPlayInfo();
    notifyListeners();
    _logger.i("TTF --- - readyToDisplay, hashCode: ${_player.hashCode}");
  }

  void _fetchedVideoModel() async {
    _logger.i("TTF --- - didFetchedVideoModel, hashCode: ${_player.hashCode} ");
    final supportedResType = await _player.supportedResolutionTypes;

    resTypes.addAll(supportedResType);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _stopTrackPlayInfo();
    if (_didStartToPlay) {
      close();
    }
  }
}
