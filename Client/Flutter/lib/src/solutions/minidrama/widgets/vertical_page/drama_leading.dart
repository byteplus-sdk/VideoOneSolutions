import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/video_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/number_unit.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DramaLeading extends StatelessWidget {
  const DramaLeading({super.key, required this.videoController});

  final VideoController videoController;
  @override
  Widget build(BuildContext context) {
    final VideoMeta videoMeta = videoController.videoMeta;
    final dramaMeta = videoController.dramaMeta;

    gotoPlayer() {
      videoController.pause();
      Navigator.pushNamed(context, '/drama_player', arguments: {
        'order': videoController.videoMeta.order,
        'dramaMeta': videoController.dramaMeta,
        'currentTime': videoController.position.inSeconds,
      }).then((_) {
        videoController.play();
      });
    }

    if (videoMeta.displayType == 1) {
      return Positioned(
          left: 16.w,
          bottom: 54.w,
          child: SizedBox(
            width: 275.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: const Color.fromRGBO(255, 255, 255, 0.2),
              ),
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 12.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (videoMeta.coverUrl != null)
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(6.w),
                                  child: Image.network(
                                    videoMeta.coverUrl ?? '',
                                    width: 36.w,
                                    height: 48.w,
                                    fit: BoxFit.cover,
                                  )),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(left: 8.0).w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dramaMeta!.dramaTitle ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16.w,
                                        height: 24 / 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromRGBO(
                                            255, 255, 255, 1)),
                                  ),
                                  Opacity(
                                    opacity: 0.8,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/minidrama/common/fire.png',
                                              width: 12.w,
                                              height: 12.w),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 4.0)
                                                    .w,
                                            child: Text(
                                              formatNumberEN(
                                                  videoMeta.playTimes ?? 0),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 14.w,
                                                  height: 20 / 14,
                                                  color: const Color.fromRGBO(
                                                      255, 255, 255, 1)),
                                            ),
                                          )
                                        ]),
                                  )
                                ],
                              ),
                            ))
                          ],
                        ),
                        SizedBox(
                          height: 5.w,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 36.w,
                          child: FilledButton(
                              onPressed: gotoPlayer,
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          const Color.fromRGBO(254, 44, 85, 1)),
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.w)))),
                              child: const Text(
                                'Play Now',
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 20 / 14,
                                    color: Color.fromRGBO(255, 255, 255, 1)),
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ));
    }
    return Positioned(
        left: 16.w,
        bottom: 54.w,
        child: SizedBox(
          width: 285.w,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: gotoPlayer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.w),
                          color: const Color.fromRGBO(40, 40, 40, 0.35),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0).w,
                          child: Row(children: [
                            Image(
                                image: const AssetImage(
                                    'assets/minidrama/common/drama.png'),
                                width: 16.w,
                                height: 16.w),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: const Color.fromRGBO(
                                              255, 255, 255, 0.36),
                                          width: 1.w))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0)
                                        .w,
                                child: Text(
                                  'Short drama',
                                  style: TextStyle(
                                      fontSize: 14.w,
                                      color: Colors.white,
                                      height: 18 / 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            Container(
                                constraints: BoxConstraints(maxWidth: 160.w),
                                padding: const EdgeInsets.only(left: 4.0).w,
                                child: Text(
                                  dramaMeta!.dramaTitle ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14.w,
                                      color: Colors.white,
                                      height: 20 / 14,
                                      fontWeight: FontWeight.w500),
                                )),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 12).w,
                    child: Text(
                      '@${videoMeta.name ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14.w,
                          color: Colors.white,
                          height: 20 / 14,
                          fontWeight: FontWeight.w500),
                    )),
                Opacity(
                  opacity: 0.9,
                  child: Text(
                    '${dramaMeta.dramaTitle ?? ''} Episode ${videoMeta.order} | ${videoMeta.caption ?? ''} | ${dramaMeta.dramaTitle}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        height: 22 / 15,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.w),
                  ),
                )
              ]),
        ));
  }
}
