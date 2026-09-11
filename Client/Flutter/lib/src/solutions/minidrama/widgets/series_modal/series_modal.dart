import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/video_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/series_modal/series_pay_modal.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/drama_service.dart';

enum SeriesModalAction {
  switchSeries,
  lockAllSeries,
}

class SeriesModal extends StatelessWidget {
  const SeriesModal({
    super.key,
    required this.currentIndex,
    required this.dramaService,
    required this.dramaMeta,
    this.mode = 1,
  });

  final DramaService dramaService;
  final int currentIndex;
  final int mode; // horizontal 1, vertical 2

  final DramaMeta dramaMeta;

  VideoMeta getCurrentVideoMeta() {
    var dramaList = dramaService.dramaList;
    return dramaList[currentIndex].videoMeta;
  }

  Widget _buildModalContainer(BuildContext context,
      [decoration = const BoxDecoration()]) {
    return Container(
      margin: EdgeInsets.all(mode == 1 ? 15.0 : 0),
      padding: EdgeInsets.all(mode == 1 ? 0 : 15),
      width: MediaQuery.of(context).size.width,
      height: 487,
      decoration: decoration,
      child: Column(
        children: [
          SeriesInfo(
              isNeedUnlockButton: dramaService.dramaNeedPay,
              mode: mode,
              dramaMeta: dramaMeta,
              dramaService: dramaService),
          Expanded(
              child: SeriesList(
                  context: context,
                  mode: mode,
                  dramaMeta: dramaMeta,
                  videoMeta: getCurrentVideoMeta(),
                  dramaService: dramaService)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mode == 1) {
      return _buildModalContainer(context);
    }
    return ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
            child: _buildModalContainer(
                context,
                const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ))));
  }
}
class SeriesInfo extends StatelessWidget {
  const SeriesInfo({
    super.key,
    required this.dramaMeta,
    required this.dramaService,
    this.mode = 1,
    this.isNeedUnlockButton = false,
    this.titleTextColor = const Color.fromRGBO(202, 203, 206, 1),
    this.descriptionColor = const Color.fromRGBO(118, 121, 126, 1),
  });

  final int mode;
  final bool isNeedUnlockButton;
  final Color titleTextColor;
  final Color descriptionColor;
  final DramaMeta dramaMeta;
  final DramaService dramaService;

  Widget _buildSeriesCover() {
    return Container(
      width: 44,
      height: 63,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.network(
        dramaMeta.dramaCoverUrl ?? "",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSeriesInfo() {
    var titleTextStyle = TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: mode == 1
            ? titleTextColor
            : const Color.fromRGBO(199, 204, 214, 1));

    var descriptionTextStyle = TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: mode == 1
            ? descriptionColor
            : const Color.fromRGBO(199, 204, 214, 1));

    return Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dramaMeta.dramaTitle ?? "", style: titleTextStyle,maxLines: 2,
            overflow: TextOverflow.ellipsis,),
              Text("All episodes ${dramaMeta.dramaLength}",
                  style: descriptionTextStyle)
            ]));
  }

  void openSeriesPayModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SeriesPayModal(
          dramaMeta: dramaMeta,
          dramaService: dramaService,
        );
      },
    );
  }

  Widget _buildUnLockButton(context) {
    if (!isNeedUnlockButton) {
      return const SizedBox.shrink();
    }
    return SizedBox(
        height: 32,
        child: TextButton(
            onPressed: () {
              Navigator.of(context).pop({
                'action': SeriesModalAction.lockAllSeries,
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 221, 153, 1),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 3, right: 3),
                  child: Image.asset('assets/minidrama/common/lock_bt.png'),
                ),
                const Text(
                  "Unlock all",
                  style: TextStyle(color: Color.fromRGBO(112, 58, 23, 1)),
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 86,
        width: MediaQuery.of(context).size.width,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSeriesCover(),
              Expanded(child: _buildSeriesInfo()),
              _buildUnLockButton(context)
            ]));
  }
}

class SeriesList extends StatefulWidget {
  const SeriesList({
    super.key,
    required this.dramaMeta,
    required this.context,
    required this.dramaService,
    required this.videoMeta,
    this.mode = 1,
  });

  final BuildContext context;
  final DramaMeta dramaMeta;
  final VideoMeta videoMeta;
  final DramaService dramaService;
  final int mode;

  @override
  State<SeriesList> createState() => _SeriesListState();
}

// 剧集列表
class _SeriesListState extends State<SeriesList> {
  static const int interval = 30;
  static const int height30 = 5 * 62;
  static const int width80 = 80;

  final ScrollController scrollController = ScrollController();

  final ScrollController selectScrollController = ScrollController();

  int selectIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    var currentIndex = widget.videoMeta.order;
    setState(() {
      selectIndex = (currentIndex! / interval).truncate();
    });
    scrollController.addListener(() {
      setState(() {
        selectIndex = (scrollController.offset / height30).truncate();
      });

      double position = (scrollController.offset / height30) * width80;
      selectScrollController.jumpTo(position);
    });
  }

  void _scrollToPosition(int seriesRowNum) {
    double position = (seriesRowNum * height30).toDouble();
    scrollController.animateTo(position,
        duration: const Duration(milliseconds: 200), curve: Curves.ease);

    setState(() {
      selectIndex = seriesRowNum;
    });
  }

  List<Widget> seriesItem() {
    var buttonList = <Widget>[];
    var dramaLength = widget.dramaMeta.dramaLength;

    for (var i = 0; i < dramaLength! / interval; i++) {
      var start = (i * interval) + 1;
      var end = dramaLength - (i + 1) * interval > 0 ? (i + 1) * interval : dramaLength;
      var text = '$start-$end';
      var color = selectIndex == i
          ? const Color.fromRGBO(202, 203, 206, 1)
          : const Color.fromRGBO(118, 121, 126, 1);

      buttonList.add(Container(
        width: 80,
        height: 46,
        alignment: Alignment.centerLeft,
        child: TextButton(
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(color: color, fontWeight: FontWeight.w400),
          ),
          onPressed: () => _scrollToPosition(i),
        ),
      ));
    }
    return buttonList;
  }

  Widget _buildSeriesSelect() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: selectScrollController,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start, children: seriesItem()),
    );
  }

  List<Widget> seriesBoxItem() {
    var buttonList = <Widget>[];
    var order = widget.videoMeta.order;
    for (var i = 0; i < widget.dramaMeta.dramaLength!; i++) {
      // var isVip = widget.dramaService.dramaList[i]?.videoMeta.vip;
      var isCurrent = (order! - 1) == i;
      var isVip = widget.dramaService.dramaList[i].videoMeta.vip;
      var backgroundColor = isCurrent
          ? const Color.fromRGBO(255, 23, 100, 0.3)
          : const Color.fromRGBO(152, 154, 159, 0.2);
      var textColor = isCurrent
          ? const Color.fromRGBO(255, 23, 100, 1)
          : const Color.fromRGBO(202, 203, 206, 1);

      buttonList.add(Stack(children: [
        SizedBox(
            width: 50,
            height: 52,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'action': SeriesModalAction.switchSeries,
                  'index': i,
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: backgroundColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
              child: Text(
                (i + 1).toString(),
                style: TextStyle(color: textColor),
              ),
            )),
        Positioned(
          right: 5,
          top: 5,
          child: isCurrent
              ? Image.asset('assets/minidrama/common/living.png')
              : const SizedBox.shrink(),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: isVip
              ? Container(
                  width: 20,
                  height: 13,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(152, 154, 159, 0.3),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8),
                        topLeft: Radius.circular(8)),
                  ),
                  child: Image.asset('assets/minidrama/common/lock.png'),
                )
              : const SizedBox.shrink(),
        )
      ]));
    }
    return buttonList;
  }

  Widget _buildSeriesSelectBox() {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.vertical,
      child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: seriesBoxItem(),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(children: [
        _buildSeriesSelect(),
        Expanded(child: _buildSeriesSelectBox())
      ]),
    );
  }
}
