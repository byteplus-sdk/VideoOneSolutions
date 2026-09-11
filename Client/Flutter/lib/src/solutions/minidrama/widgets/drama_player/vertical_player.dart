import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_player/speed_setting.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/series_modal/series_modal.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/drama_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/player_controller.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/common/keep_alive_wrapper.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/vertical_page/vertical_video_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerticalPlayer extends StatefulWidget {
  const VerticalPlayer(
      {super.key,
      required this.playerController,
      required this.dramaService,
      required this.defaultOrder,
      required this.dramaMeta,
      required this.doUnlock,
      this.currentTime = 0 
      });

  final PlayerController playerController;

  final DramaService dramaService;

  final int defaultOrder;
  final double currentTime;

  final Future<void> Function([int? order]) doUnlock;

  final DramaMeta dramaMeta;
  @override
  State<VerticalPlayer> createState() => _VerticalPlayerState();
}

class _VerticalPlayerState extends State<VerticalPlayer> {
  late PageController _pageController;

  int curOrder = 1;

  @override
  void initState() {
    super.initState();
    for (var item in widget.dramaService.dramaList) {
      item.setDramaMeta(widget.dramaMeta);
    }
    curOrder = widget.defaultOrder;
    widget.playerController.addVideos(widget.dramaService.dramaList);
    widget.playerController.setCurVideoVidByIndex(widget.defaultOrder - 1);
    

    _pageController = PageController(initialPage: widget.defaultOrder - 1);

    _pageController.addListener(() {
      int nextPage = _pageController.page!.round();
      if (nextPage != curOrder - 1) {
        final order = nextPage + 1;
        setState(() {
          curOrder = order;
        });
        // 如果当前集数是Vip 则调用doUnlock
        if (widget.playerController
            .getVideoControllerByIndex(nextPage)!
            .isVip) {
          widget.doUnlock(order);
        }
      }
    });
    Future.microtask(() {
      final curVideoController =
          widget.playerController.getCurrentVideoController();
      curVideoController?.play();

      if(widget.currentTime > 0){
        Future.delayed(const Duration(milliseconds: 1000), () {
          curVideoController?.seekToTimeMs(widget.currentTime * 1000);
        });
      }
      // 如果当前集数是Vip 则调用doUnlock
      if (curVideoController!.isVip) {
        widget.doUnlock(curOrder);
      }
    });
  }

  Future<void> showSeriesSelect() async {
    final result = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        builder: (builder) {
          return SeriesModal(
            currentIndex: curOrder - 1,
            dramaMeta: widget.dramaMeta,
            dramaService: widget.dramaService,
            mode: 1,
          );
        });
    if (result != null) {
      if (result['action'] == SeriesModalAction.switchSeries) {
        final index = result['index'];
        _pageController.jumpToPage(index);
        return;
      }

      if (result['action'] == SeriesModalAction.lockAllSeries) {
        widget.doUnlock();
        return;
      }
      
    }
  }

  @override
  dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late double paddingBottom = 0;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    if (paddingBottom == 0) {
      paddingBottom = padding.bottom;
    }
    return Stack(children: [
      Column(
        children: [
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.dramaService.dramaList.length,
              onPageChanged: _pageChange,
              itemBuilder: (context, index) {
                final videoController =
                    widget.playerController.getVideoControllerByIndex(index);
                final currentVideoController =
                    widget.playerController.getCurrentVideoController();
                if (currentVideoController == null) {
                  widget.playerController.setCurVideoVidByIndex(index);
                }
                if (videoController!.isVip) {
                  return GestureDetector(
                    onTap: () {
                      widget.doUnlock(curOrder);
                    },
                    child: SizedBox.expand(
                      child: Image(
                        image:
                            NetworkImage(videoController.videoMeta.coverUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }

                if(videoController!.isVip == true || index != curOrder - 1){
                  videoController.pause();
                }

                return KeepAliveWrapper(
                  child: VerticalVideoPage(
                      videoController: videoController,
                      showLeading: false,
                      showRecommend: false,
                      showLeadingAvatar: false),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: paddingBottom),
            child: SizedBox(
              height: 48.w,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16.0, 12, 16, 0).w,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showSeriesSelect();
                      },
                      child: Container(
                        width: 289.w,
                        height: 32.w,
                        padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16)
                            .w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15.w),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/minidrama/common/series_icon.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                                child: Text(
                              'Full Episodes · ${widget.dramaService.dramaList.length} videos',
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 16 / 14,
                                  color: Colors.white),
                            )),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0).w,
                              child: Transform.rotate(
                                angle: 0.5 * pi,
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.playerController.getCurrentVideoController() !=
                        null)
                      Expanded(
                          child: ListenableBuilder(
                        builder: (context, child) {
                          final videoController = widget.playerController
                              .getCurrentVideoController();
                          return GestureDetector(
                            onTap: () => _changeSpeed(context, videoController),
                            child: Center(
                              child: Text('${videoController!.speed.speed}x',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                        listenable: widget.playerController
                            .getCurrentVideoController()!,
                      ))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      Positioned(
          top: padding.top + 5.w,
          left: 24.w,
          child: GestureDetector(
            onTap: () {
              widget.playerController.getCurrentVideoController()?.pause();
              Navigator.pop(context);
            },
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                Text(
                  'Episode $curOrder',
                  style: const TextStyle(
                      fontSize: 18,
                      height: 26 / 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(255, 255, 255, 1)),
                )
              ],
            ),
          ))
    ]);
  }

  _changeSpeed(BuildContext context, VideoController videoController) async {
    return showModalBottomSheet<int>(
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.4,
      builder: (BuildContext context) {
        return SpeedSetting(videoController: videoController);
      },
    );
  }

  _pageChange(int index) {
    setState(() {
      curOrder = index + 1;
    });
    widget.playerController.pauseCurrentVideo();
    widget.playerController.setCurVideoVidByIndex(index);
    widget.playerController.getCurrentVideoController()?.play();
  }
}
