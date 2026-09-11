import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/comment_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/avatar.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/number_unit.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/comment/comments_draw_content.dart';
import 'package:byteplus_vod/ve_vod.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/vertical_page/drama_leading.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/vertical_page/recommend_bar.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_player/video_control.dart';

enum AnimType {
  like,
  unlike,
}

class VerticalVideoPage extends StatefulWidget {
  const VerticalVideoPage(
      {super.key,
      required this.videoController,
      this.showLeading = true,
      this.showRecommend = true,
      this.showLeadingAvatar = true});
  final VideoController videoController;

  final bool showLeading;
  final bool showRecommend;
  final bool showLeadingAvatar;

  @override
  State<VerticalVideoPage> createState() => _VerticalVideoPageState();
}

class _VerticalVideoPageState extends State<VerticalVideoPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLikeLocally = false;

  int _commentCount = 0;

  int _likeCount = 0;

  AnimType? _animType;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.videoController.videoMeta.comment ?? 0;
    _likeCount = widget.videoController.videoMeta.like ?? 0;
  }

  Future<void> _like() async {
    setState(() {
      _animType = _isLikeLocally ? AnimType.like : AnimType.unlike;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _animType = null;
      _isLikeLocally = !_isLikeLocally;
      if (_isLikeLocally) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
  }

  Future<int?> _showComment() {
    final comments = Comments(vid: widget.videoController.videoMeta.vid!);
    return showModalBottomSheet<int>(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      context: context,
      builder: (BuildContext context) {
        return CommentsDrawContent(comments: comments);
      },
    );
  }

  gotoPlayer() {
    widget.videoController.pause();
    Navigator.pushNamed(context, '/drama_player', arguments: {
      'order': widget.videoController.videoMeta.order,
      'dramaMeta': widget.videoController.dramaMeta,
      'currentTime': widget.videoController.position.inSeconds,
    }).then((_) {
      widget.videoController.play();
    });
  }

  _horizontalVideo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final VideoController videoController = widget.videoController;
    final videoWidth = videoController.videoMeta.width!;
    final renderHeight =
        videoController.videoMeta.height! * screenWidth / videoWidth;

    return Center(
        child: SizedBox(
      height: renderHeight + 88.w,
      child: Stack(
        children: [
          Center(
              child: SizedBox(
                  height: renderHeight, child: videoController.getPlayView())),
          if (!videoController.didVideoReady)
            Center(
                child: SizedBox(
              height: renderHeight,
              child: Image(
                image: NetworkImage(videoController.videoMeta.coverUrl!),
                fit: BoxFit.cover,
              ),
            )),
          GestureDetector(
            onTap: () => {
              if (videoController.getPlayStatus() ==
                  TTVideoEnginePlaybackState.playing)
                {videoController.pause()}
              else
                {videoController.play()}
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: screenWidth,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    gotoPlayer();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 12.w),
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.2),
                          width: 1,
                        ),
                        color: const Color.fromRGBO(41, 41, 41, 0.34)),
                    child: SizedBox(
                      width: 98.w,
                      height: 32.w,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: Image.asset(
                                  'assets/minidrama/common/player/fullscreen.png'),
                            ),
                            Text(
                              'Full screen',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  height: 16.sp / 12,
                                  color: Colors.white),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final videoMeta = widget.videoController.videoMeta;
    final videoController = widget.videoController;
    return ListenableBuilder(
      listenable: widget.videoController,
      builder: (context, child) {
        final loadStatus = videoController.getLoadStatus();
        return Stack(children: [
          !videoController.isVertical
              ? _horizontalVideo(context)
              : _verticalVideo(videoController),
          // 加载中
          if (videoController.didStartToPlay &&
              (loadStatus == null ||
                  loadStatus == TTVideoEngineLoadState.stalled))
            const Center(child: CircularProgressIndicator()),
          GestureDetector(
            onTap: () => {
              if (videoController.getPlayStatus() ==
                  TTVideoEnginePlaybackState.playing)
                {videoController.pause()}
              else
                {videoController.play()}
            },
            child: VideoControl(videoController: videoController),
          ),
          if (widget.showLeading)
            DramaLeading(videoController: videoController),
          if (widget.showRecommend)
            RecommendBar(
              videoController: videoController,
            ),
          Positioned(
              right: 6.w,
              bottom: 54.w,
              child: SizedBox(
                  height: 200.w,
                  width: 44.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (videoMeta.uid != null && widget.showLeadingAvatar)
                        DecoratedBox(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22.w),
                                border: Border.all(
                                    color: Colors.white, width: 2.w)),
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              child: ClipOval(
                                child: Image.asset(
                                    getAvatarUrl(videoMeta.uid.toString()),
                                    height: 40.w,
                                    width: 40.w),
                              ),
                            )),
                      SizedBox(height: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Stack(children: [
                              if (_animType == null)
                                GestureDetector(
                                  onTap: () {
                                    _like();
                                  },
                                  child: Image.asset(
                                    _isLikeLocally
                                        ? 'assets/minidrama/common/like.png'
                                        : 'assets/minidrama/common/unlike.png',
                                    height: 44.w,
                                    width: 44.w,
                                  ),
                                ),
                              if (_animType != null)
                                Lottie.asset(
                                  _animType == AnimType.unlike
                                      ? 'assets/minidrama/lotties/like_icondata.json'
                                      : 'assets/minidrama/lotties/like_cancel.json',
                                  height: 44.w,
                                  width: 44.w,
                                )
                            ]),
                          ),
                          Text(
                            formatNumberEN(_likeCount),
                            style: TextStyle(
                                fontSize: 14.w,
                                height: 20 / 14,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showComment();
                            },
                            child: Image.asset(
                              'assets/minidrama/common/comment.png',
                              height: 44.w,
                              width: 44.w,
                            ),
                          ),
                          Text(
                            formatNumberEN(_commentCount),
                            style: TextStyle(
                                fontSize: 14.w,
                                height: 20 / 14,
                                color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  )))
        ]);
      },
    );
  }

  _verticalVideo(VideoController videoController) {
    return Stack(children: [
      videoController.getPlayView(),
      if (videoController.didVideoReady == false)
        SizedBox.expand(
          child: Image(
            image: NetworkImage(videoController.videoMeta.coverUrl!),
            fit: BoxFit.cover,
          ),
        )
    ]);
  }
}
