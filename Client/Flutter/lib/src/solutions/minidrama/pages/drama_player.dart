import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/pages/ad_player.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_player/horizontal_player.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_player/vertical_player.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/series_modal/series_pay_modal.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/series_modal/single_unlock_modal.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/drama_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/player_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:logger/logger.dart';
import 'package:loader_overlay/loader_overlay.dart';

final Logger _logger = Logger();

class DramaPlayerView extends StatefulWidget {
  const DramaPlayerView({super.key});
  static const routeName = '/drama_player';

  @override
  State<DramaPlayerView> createState() => _DramaPlayerViewState();
}

class _DramaPlayerViewState extends State<DramaPlayerView>
    with WidgetsBindingObserver {
  late final PlayerController playerController;

  late int defaultOrder = 1;

  late DramaMeta dramaMeta;

  late DramaService dramaService;

  late int dramaVideoOrientation;

  late Future<Null> ready;

  late Future<void> initFuture;

  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);

    initAppLifecycleListener();

    ready = Future.microtask(() {
      final dramaInfo =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      dramaMeta = dramaInfo['dramaMeta'] as DramaMeta;
      defaultOrder = (dramaInfo['order'] ?? 1) as int;
      dramaVideoOrientation = dramaMeta.dramaVideoOrientation!;
      playerController = PlayerController();
      dramaService = DramaService(dramaId: dramaMeta.dramaId!);
    });
    initFuture = _init();
  }

  Future<void> _init() async {
    await ready;
    // 竖屏
    if (dramaMeta.dramaVideoOrientation == 0) {
      await dramaService.loadDramaList();
    } else {
      await Future.wait([
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft]),
        dramaService.loadDramaList(),
      ]);
    }
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
        playerController.getCurrentVideoController();
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

  reload() {
    setState(() {
      initFuture = _init();
    });
  }

  @override
  void dispose() {
    playerController.dispose();
    dramaService.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> doUnlock([int? order]) async {
    if (order == null) {
      unLockAll();
      return;
    }
    final result = await showDialog<LockSelect?>(
        context: context,
        builder: (context) {
          return SingleUnLockModal(
              dramaMeta: dramaMeta, dramaService: dramaService);
        });
    // 单集解锁
    if (result == LockSelect.unlockSingle) {
      final adResult = await Navigator.pushNamed(context, '/ad_player');
      if (adResult != AdWatchStatus.enough) {
        return;
      }
      try {
        context.loaderOverlay.show();

        await dramaService.unlockDrama(
            [dramaService.getDramaItemByIndex(order - 1)!.videoMeta.vid!]);
        playerController.updateVideo(dramaService.dramaList);
        context.loaderOverlay.hide();

        setState(() {});
        Future.microtask(() {
          playerController.getVideoControllerByIndex(order - 1)!.play();
        });
      } catch (e) {
        context.loaderOverlay.hide();

        Fluttertoast.showToast(
            msg: 'Unlock failed',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      return;
    }
    // 全部解锁
    if (result == LockSelect.unlockAll) {
      unLockAll();
      return;
    }
  }

  Future<void> unLockAll() async {
    final result = await showModalBottomSheet(
        context: context,
        scrollControlDisabledMaxHeightRatio:
            dramaMeta.dramaVideoOrientation == 0 ? 0.5 : 0.9,
        builder: (builder) {
          if (dramaMeta.dramaVideoOrientation == 0) {
            return SeriesPayModal(
                dramaMeta: dramaMeta, dramaService: dramaService);
          }
          return FractionallySizedBox(
              widthFactor: 0.7,
              child: SeriesPayModal(
                  dramaMeta: dramaMeta, dramaService: dramaService));
        });
    if (result == null) {
      return;
    }
    context.loaderOverlay.show();
    final lockVidList = result == UnlockType.unlockAll
        ? dramaService.getAllUnlockVid()
        : dramaService.getNext10UnlockVid();
    try {
      await dramaService.unlockDrama(lockVidList);
      playerController.updateVideo(dramaService.dramaList);
      context.loaderOverlay.hide();
      setState(() {});

      Fluttertoast.showToast(
        msg: 'Unlock success',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Future.microtask(() {
        playerController.getVideoControllerByVid(lockVidList.first)!.play();
      });
    } catch (e) {
      context.loaderOverlay.hide();

      Fluttertoast.showToast(
          msg: 'Unlock failed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {

    final dramaInfo =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final currentTime = dramaInfo['currentTime']!=null ? double.parse(dramaInfo['currentTime'].toString()) : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
        future: initFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const Text('Loading failed',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  FilledButton(onPressed: reload, child: const Text('Retry')),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (dramaMeta.dramaVideoOrientation == 1) {
              return HorizontalPlayer(
                playerController: playerController,
                dramaService: dramaService,
                defaultOrder: defaultOrder,
                dramaMeta: dramaMeta,
                currentTime: currentTime,
                doUnlock: doUnlock,
              );
            }
            return VerticalPlayer(
              playerController: playerController,
              dramaService: dramaService,
              defaultOrder: defaultOrder,
              dramaMeta: dramaMeta,
              currentTime: currentTime,
              doUnlock: doUnlock,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
