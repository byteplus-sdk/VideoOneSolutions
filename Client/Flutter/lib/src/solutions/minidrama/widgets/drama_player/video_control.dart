import 'package:byteplus_vod/ve_vod.dart';
import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoControl extends StatefulWidget {
  const VideoControl({
    super.key,
    required this.videoController,
  });
  final VideoController videoController;

  @override
  State<VideoControl> createState() => _VideoControlState();
}

class _VideoControlState extends State<VideoControl> {
  double progress = 0;

  bool _isSeeking = false;

  @override
  Widget build(BuildContext context) {
    final videoMeta = widget.videoController.videoMeta;
    return SizedBox.expand(
        child: ListenableBuilder(
            listenable: widget.videoController,
            builder: (context, child) {
              return Stack(
                children: [
                  if (widget.videoController.didVideoReady &&
                      widget.videoController.isVertical == true)
                    GestureDetector(
                      onTap: () => {
                        if (widget.videoController.getPlayStatus() ==
                            TTVideoEnginePlaybackState.playing)
                          {widget.videoController.pause()}
                        else
                          {widget.videoController.play()}
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  Positioned(
                      bottom: 2.w,
                      left: 10.w,
                      right: 10.w,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.w,
                          trackShape: const RectangularSliderTrackShape(),
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 5.w,
                          ),
                          thumbColor: Colors.white,
                          activeTrackColor: Colors.white,
                          secondaryActiveTrackColor:
                              Colors.white.withOpacity(0.5),
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 5.w,
                          ),
                        ),
                        child: Slider(
                          min: 0,
                          max: videoMeta.duration! * 1000,
                          value: _isSeeking
                              ? progress
                              : widget.videoController.position.inMilliseconds
                                  .toDouble(),
                          secondaryTrackValue: widget
                              .videoController.positionDuration.inMilliseconds
                              .toDouble(),
                          onChanged: (value) {
                            setState(() {
                              progress = value;
                            });
                          },
                          onChangeStart: (value) {
                            setState(() {
                              _isSeeking = true;
                              progress = value;
                            });
                          },
                          onChangeEnd: (value) {
                            widget.videoController
                                .seekToTimeMs(value)
                                .then((_) => {
                                      setState(() {
                                        _isSeeking = false;
                                        progress = value;
                                      })
                                    });
                          },
                        ),
                      )),
                  if (widget.videoController.didVideoReady &&
                      widget.videoController.getPlayStatus() ==
                          TTVideoEnginePlaybackState.paused)
                    Center(
                      child: Image.asset(
                        'assets/minidrama/common/player/btn_play.png',
                        width: 44.w,
                        height: 44.w,
                      ),
                    )
                ],
              );
            }));
  }
}
