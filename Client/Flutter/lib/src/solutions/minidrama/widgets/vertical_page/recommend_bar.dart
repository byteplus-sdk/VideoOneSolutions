import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/drama_service.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/number_unit.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/utils.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';

class RecommendBar extends StatefulWidget {
  const RecommendBar({
    super.key,
    required this.videoController,
  });

  final VideoController videoController;

  @override
  State<RecommendBar> createState() => _RecommendBarState();
}

class _RecommendBarState extends State<RecommendBar> {
  late DramaService _dramaService;

  @override
  void initState() {
    super.initState();
    _dramaService =
        DramaService(dramaId: widget.videoController.dramaMeta!.dramaId!);
  }

  gotoPlayer(int order) {
    widget.videoController.pause();
    Navigator.pushNamed(context, '/drama_player', arguments: {
      'order': order,
      'dramaMeta': widget.videoController.dramaMeta,
      'currentTime': widget.videoController.position.inSeconds,
    }).then((_) {
        widget.videoController.play();
    });
  }
  
  _showRecommend() async {
    showModalBottomSheet<int>(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      scrollControlDisabledMaxHeightRatio: 0.7,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(children: [
              Stack(children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.w),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Image(
                          image: AssetImage('assets/minidrama/common/union.png'),
                          width: 12,
                          height: 12,
                        ),
                        SizedBox(width: 4.w),
                        const Text(
                          'Recommend for you',
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(255, 255, 255, 0.9),
                          ),
                        ),
                      ]),
                ),
                Positioned(
                  right: 16.w,
                  top: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0).w,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18.w,
                      ),
                    ),
                  ),
                )
              ]),
              Expanded(
                  child: !_dramaService.dramaList!.isEmpty
                      ? _renderDramaList()
                      : FutureBuilder(
                          future: _dramaService.loadDramaList(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return _renderDramaList();
                            }
                            return const Center(
                                child: CircularProgressIndicator(
                              color: Colors.white70,
                            ));
                          }))
            ]),
          ),
        );
      },
    );
  }

  _renderDramaList() {
    return ListView.builder(
      itemCount: _dramaService.dramaList!.length,
      itemBuilder: (context, index) {
        final item = _dramaService.getDramaItemByIndex(index);
        return GestureDetector(
          onTap: () {
            gotoPlayer(item.videoMeta.order!);
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
              color: item!.videoMeta.vid == widget.videoController.videoMeta.vid
                  ? const Color.fromRGBO(255, 255, 255, 0.12)
                  : null,
              height: 104.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image(
                      image: NetworkImage(item.videoMeta.coverUrl!),
                      width: 64.w,
                      height: 84.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0).w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.videoController.dramaMeta!.dramaTitle}|${item.videoMeta.caption!}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.w),
                        Row(
                          children: [
                            Text(
                                formatSeconds(item.videoMeta.duration!.toInt()),
                                style: const TextStyle(
                                  color: Color.fromRGBO(115, 122, 135, 1),
                                  fontSize: 14,
                                  height: 20 / 14,
                                )),
                            SizedBox(width: 4.w),
                            Image(
                              image: const AssetImage(
                                  'assets/minidrama/common/fire.png'),
                              width: 12.w,
                              height: 12.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              formatNumberEN(item.videoMeta.playTimes!),
                              style: const TextStyle(
                                color: Color.fromRGBO(115, 122, 135, 1),
                                fontSize: 14,
                                height: 20 / 14,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ))
                ],
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12.w,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _showRecommend,
        child: Container(
          color: const Color.fromRGBO(7, 8, 10, 0.40),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    child: const Image(
                      image: AssetImage(
                        'assets/minidrama/common/union.png',
                      ),
                      width: 12,
                      height: 12,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Recommend for you · ${widget.videoController.dramaMeta!.dramaLength} Videos',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 12.w,
              )
            ],
          ),
        ),
      ),
    );
  }
}
