import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/number_unit.dart';

class DramaCover extends StatelessWidget {
  const DramaCover({
    super.key,
    required this.coverImg,
    this.width,
    this.height,
    this.tlBadge,
    this.blBadge,
    this.aspect = 3 / 4,
  });

  final double? width;
  final double? height;
  final Image coverImg;
  final Widget? tlBadge;
  final Widget? blBadge;
  final double? aspect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AspectRatio(
          aspectRatio: aspect!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                coverImg,
                Positioned(
                  top: 0,
                  left: 0,
                  child: tlBadge == null ? const SizedBox.shrink() : tlBadge!,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: blBadge == null ? const SizedBox.shrink() : blBadge!,
                )
              ],
            ),
          )),
    );
  }
}

class PlayCount extends StatelessWidget {
  const PlayCount({
    super.key,
    required this.count,
    this.margin = const EdgeInsets.all(0),
  });

  final int count;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: [
          Image.asset(
            'assets/minidrama/common/player/btn_play.png',
            width: 16,
            height: 16,
          ),
          Text(
            formatNumber(count),
            style: const TextStyle(
              shadows: [
                Shadow(
                    color: Color.fromARGB(38, 0, 0, 0),
                    blurRadius: 1,
                    offset: Offset(0, 1))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoverBadge extends StatelessWidget {
  const CoverBadge({
    super.key,
    required this.text,
    this.gradientColor,
    this.textColor = Colors.white,
  });

  final String text;
  final Gradient? gradientColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.w),
                bottomRight: Radius.circular(8.w)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(gradient: gradientColor),
              height: 16.w,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            )));
  }
}

class DramaTitle extends StatelessWidget {
  const DramaTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.w),
    );
  }
}

class PlayNowButton extends StatelessWidget {
  const PlayNowButton({super.key, required this.id, required this.dramaMeta});

  final String id;

  final DramaMeta dramaMeta;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 18.w,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/drama_player',
              arguments: {'dramaMeta': dramaMeta, 'order': 1});
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.w),
          child: Container(
            width: 120.w,
            height: 32.w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 23, 100),
                  Color.fromARGB(255, 237, 53, 150),
                ],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/minidrama/common/player/btn_play.png',
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  const Text(
                    'Play Now',
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
