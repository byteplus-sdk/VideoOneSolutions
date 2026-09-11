import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_player/horizontal_video_control.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/series_modal/series_modal.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/drama_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/player_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/common/keep_alive_wrapper.dart';

class HorizontalPlayer extends StatefulWidget {
  const HorizontalPlayer(
      {super.key,
        required this.playerController,
        required this.dramaService,
        required this.defaultOrder,
        required this.dramaMeta,
        required this.doUnlock,
        this.currentTime = 0 ,
      });

  final PlayerController playerController;
  final DramaService dramaService;
  final int defaultOrder;
  final DramaMeta dramaMeta;
  final double currentTime;

  final Future<void> Function([int? order]) doUnlock;

  @override
  State<HorizontalPlayer> createState() => _HorizontalPlayerState();
}

class _HorizontalPlayerState extends State<HorizontalPlayer> {
  // 当前的剧集

  late int currentOrder = 1;

  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    for (var item in widget.dramaService.dramaList) {
      item.setDramaMeta(widget.dramaMeta);
    }
    widget.playerController.addVideos(widget.dramaService.dramaList);
    widget.playerController.setCurVideoVidByIndex(widget.defaultOrder - 1);
   
    currentOrder = widget.defaultOrder;
    pageController = PageController(initialPage: currentOrder - 1);
    Future.microtask(() {
      final curVideoController =
          widget.playerController.getCurrentVideoController();
      curVideoController?.play();

      if(widget.currentTime > 0){
        Future.delayed(const Duration(milliseconds: 1000), () {
          curVideoController?.seekToTimeMs(widget.currentTime * 1000);
        });
      }
  
      if (curVideoController!.isVip) {
        widget.doUnlock(currentOrder);
      }
    });
  }

  @override
  dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> showSeriesSelect() async {
    final result = await showModalBottomSheet(
        context: context,
        scrollControlDisabledMaxHeightRatio: 0.9,
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints.expand(),
        builder: (builder) {
          return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.transparent,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          padding: const EdgeInsets.only(right: 30).w,
                          child: SeriesModal(
                            currentIndex: currentOrder - 1,
                            dramaMeta: widget.dramaMeta,
                            dramaService: widget.dramaService,
                            mode: 0,
                          ),
                        ))),
              ));
        });
    if (result != null) {
      if (result['action'] == SeriesModalAction.switchSeries) {
        final index = result['index'];
        if (index == currentOrder - 1) {
          return;
        }
        widget.playerController.getCurrentVideoController()?.pause();
        widget.playerController.setCurVideoVidByIndex(index);
        setState(() {
          currentOrder = index + 1;
        });
        pageController.jumpToPage(index);
        if (widget.playerController.getCurrentVideoController()!.isVip) {
          widget.doUnlock(index + 1);
        }

        widget.playerController.getCurrentVideoController()?.play();
        return;
      }
      if (result['action'] == SeriesModalAction.lockAllSeries) {
        widget.doUnlock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: widget.dramaService.dramaList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (builder, idx) {
          final curVideoController =
              widget.playerController.getVideoControllerByIndex(idx);
          if (curVideoController!.isVip == true || idx != currentOrder - 1) {
            curVideoController.pause();
          }

          return KeepAliveWrapper(child: _videoRendered(idx));
        });
  }

  _videoRendered(int idx) {
    final curVideoController =
        widget.playerController.getVideoControllerByIndex(idx);
    final curPlayView = curVideoController!.getPlayView();
    return Stack(children: [
      SizedBox.expand(
        child: Image(
          image: NetworkImage(curVideoController.videoMeta.coverUrl!),
          fit: BoxFit.fitHeight,
        ),
      ),
      if (!curVideoController.isVip) curPlayView,
      HorizontalVideoControl(
          playerController: widget.playerController,
          videoController: curVideoController,
          doUnlock: widget.doUnlock,
          showSeriesSelect: showSeriesSelect)
    ]);
  }
}
