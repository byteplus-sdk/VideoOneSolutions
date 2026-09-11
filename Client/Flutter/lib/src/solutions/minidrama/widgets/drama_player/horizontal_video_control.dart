import 'package:byteplus_vod/ve_vod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_player/resolution_setting.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_player/speed_setting.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/comment_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/utils.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/player_controller.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/comment/comments_draw_content.dart';

class HorizontalVideoControl extends StatefulWidget {
  const HorizontalVideoControl(
      {super.key,
      required this.playerController,
      required this.videoController,
      required this.showSeriesSelect,
      required this.doUnlock});

  final PlayerController playerController;

  final VideoController videoController;
  final Future<void> Function([int? order]) doUnlock;

  final Future<void> Function() showSeriesSelect;

  @override
  State<HorizontalVideoControl> createState() => _HorizontalVideoControlState();
}

class _HorizontalVideoControlState extends State<HorizontalVideoControl> {
  bool showHandler = false;

  @override
  Widget build(BuildContext context) {
    final decoration = showHandler
        ? BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.12),
                Colors.black.withOpacity(0.12),
                Colors.black.withOpacity(0.5),
              ],
                stops: const [
                0,
                0.3,
                0.7,
                1
              ]))
        : const BoxDecoration(
            color: Colors.transparent,
          );
    return GestureDetector(
      onTap: () => setState(() {
        if (widget.videoController.isVip) {
          widget.doUnlock(widget.videoController.videoMeta.order);
          return;
        }
        showHandler = !showHandler;
      }),
      child: Container(
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 43, vertical: 16).h,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.centerLeft,
          children: showHandler
              ? [
                  _loading(),
                  _backWidget(),
                  _sliderWidget(),
                  Positioned.fill(
                    child:
                        Align(alignment: Alignment.center, child: _playBtn()),
                  ),
                  _commentAndLike(),
                  _speedAndQuantity(),
                ]
              : [_loading()],
        ),
      ),
    );
  }

  void popPage() async{
    await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });
  }

  _backWidget() {
    return Positioned(
        top: 16.h,
        left: 0.h,
        child: GestureDetector(
          onTap: () {
            popPage();
          },
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              Text(
                'Episode ${widget.videoController.videoMeta.order}',
                style: const TextStyle(
                    fontSize: 18,
                    height: 26 / 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(255, 255, 255, 1)),
              )
            ],
          ),
        ));
  }

  double position = 0;
  bool isSeeking = false;

  _sliderWidget() {
    return Positioned(
      bottom: 60.h,
      left: 10.h,
      right: 10.h,
      child: ListenableBuilder(
          listenable: widget.videoController,
          builder: (context, child) {
            final value = isSeeking
                ? position
                : widget.videoController.position.inMilliseconds.toDouble();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 3).h,
                  child: Row(
                    children: [
                      Text(
                        formatSeconds((value / 1000).toInt()),
                        style: const TextStyle(
                            fontSize: 14,
                            height: 16 / 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      Text(
                          ' / ${formatSeconds(widget.videoController.videoMeta.duration!.toInt())}',
                          style: TextStyle(
                            fontSize: 14,
                            height: 16 / 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.64),
                          ))
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.h,
                    trackShape: const RectangularSliderTrackShape(),
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 6.h,
                    ),
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.white,
                    secondaryActiveTrackColor: Colors.white.withOpacity(0.5),
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 5.h,
                    ),
                  ),
                  child: Slider(
                      value: value,
                      min: 0,
                      max: widget.videoController.videoMeta.duration! *
                          1000.toDouble(),
                      secondaryTrackValue: widget
                          .videoController.positionDuration.inMilliseconds
                          .toDouble(),
                      onChangeStart: (value) {
                        setState(() {
                          isSeeking = true;
                        });
                      },
                      onChangeEnd: (value) {
                        widget.videoController.seekToTimeMs(value).then((_) {
                          setState(() {
                            position = value;
                            isSeeking = false;
                          });
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          position = value;
                        });
                      }),
                )
              ],
            );
          }),
    );
  }

  _playBtn() {
    return ListenableBuilder(
        listenable: widget.videoController,
        builder: (context, child) {
          if (widget.videoController.didVideoReady) {
            return GestureDetector(
              onTap: () {
                if (widget.videoController.getPlayStatus() ==
                    TTVideoEnginePlaybackState.playing) {
                  widget.videoController.pause();
                } else {
                  widget.videoController.play();
                }
              },
              child: Image.asset(
                widget.videoController.getPlayStatus() !=
                        TTVideoEnginePlaybackState.paused
                    ? 'assets/minidrama/common/player/btn_pause.png'
                    : 'assets/minidrama/common/player/btn_play.png',
                height: 64.h,
                width: 64.w,
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }

  bool liked = false;

  Future<int?> _showComment() {
    final comments = Comments(vid: widget.videoController.videoMeta.vid!);
    return showModalBottomSheet<int>(
      scrollControlDisabledMaxHeightRatio: 0.9,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      context: context,
      constraints: const BoxConstraints.expand(),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30).h,
                      child: CommentsDrawContent(comments: comments),
                    ))),
          ),
        );
      },
    );
  }

  _commentAndLike() {
    return Positioned(
      bottom: 16.h,
      left: 8.h,
      child: ListenableBuilder(
        listenable: widget.videoController,
        builder: (context, child) {
          final videoMeta = widget.videoController.videoMeta;
          return Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      liked = !liked;
                    }),
                    child: Image(
                        image: AssetImage(liked
                            ? 'assets/minidrama/common/player/v_like.png'
                            : 'assets/minidrama/common/player/v_unlike.png'),
                        height: 40.h,
                        width: 40.h),
                  ),
                  Positioned(
                    bottom: 6.h,
                    right: 6.h,
                    child: Text(
                      '${liked ? videoMeta.like! + 1 : videoMeta.like}',
                      style: const TextStyle(
                          fontSize: 10,
                          height: 12 / 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
              SizedBox(width: 24.h),
              Stack(alignment: Alignment.bottomRight, children: [
                GestureDetector(
                  onTap: _showComment,
                  child: Image(
                      image: const AssetImage(
                          'assets/minidrama/common/player/v_comment.png'),
                      height: 40.h,
                      width: 40.h),
                ),
                Positioned(
                  bottom: 6.h,
                  right: 6.h,
                  child: Text(
                    '${videoMeta.comment}',
                    style: const TextStyle(
                        fontSize: 10,
                        height: 12 / 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                )
              ])
            ],
          );
        },
      ),
    );
  }

  _changeSpeed(BuildContext context, VideoController videoController) async {
    return showModalBottomSheet<int>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.8,
      constraints: const BoxConstraints.expand(),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                    widthFactor: 0.3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30).h,
                      child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.black),
                          child:
                              SpeedSetting(videoController: videoController)),
                    ))),
          ),
        );
      },
    );
  }

  _changeResolution(
      BuildContext context, VideoController videoController) async {
    return showModalBottomSheet<int>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.8,
      constraints: const BoxConstraints.expand(),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                    widthFactor: 0.3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30).h,
                      child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.black),
                          child: ResolutionSetting(
                              videoController: videoController)),
                    ))),
          ),
        );
      },
    );
  }

  _speedAndQuantity() {
    return Positioned(
        bottom: 26.h,
        right: 8.h,
        child: ListenableBuilder(
            listenable: widget.videoController,
            builder: (context, child) {
              return Row(children: [
                GestureDetector(
                  onTap: () => _changeSpeed(context, widget.videoController),
                  child: Row(
                    children: [
                      Image(
                          image: const AssetImage(
                              'assets/minidrama/common/player/v_speed.png'),
                          height: 21.h,
                          width: 21.h),
                      Text(
                        '${widget.videoController.speed.speed}x',
                        style: const TextStyle(
                            fontSize: 15,
                            height: 24 / 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
                SizedBox(width: 32.h),
                GestureDetector(
                  onTap: () =>
                      _changeResolution(context, widget.videoController),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/minidrama/common/player/v_quantity.png',
                        width: 20.h,
                        height: 20.h,
                      ),
                      SizedBox(width: 4.h),
                      Text(
                        '${VideoResolution.getVideoResolutionByName(widget.videoController.resolution.name)}',
                        style: const TextStyle(
                            fontSize: 15,
                            height: 24 / 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
                SizedBox(width: 32.h),

                GestureDetector(
                  onTap: () {
                    widget.showSeriesSelect();
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/minidrama/common/player/series.png',
                        width: 20.h,
                        height: 20.h,
                      ),
                      SizedBox(width: 4.h),
                      Text(
                        '${widget.playerController.videoCount}',
                        style: const TextStyle(
                            fontSize: 15,
                            height: 24 / 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      )
                    ],
                  ),
                )
              ]);
            }));
  }

  _loading() {
    return ListenableBuilder(
      listenable: widget.videoController,
      builder: (BuildContext context, child) {
        final loadStatus = widget.videoController.getLoadStatus();
        if (widget.videoController.didStartToPlay &&
            (loadStatus == null ||
                loadStatus == TTVideoEngineLoadState.stalled)) {
          return const Center(child: CircularProgressIndicator());
        }
        return const SizedBox.shrink();
      },
    );
  }
}
