import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_channel/constants.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/drama_channel/drama_component.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/number_unit.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/request.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constants/api.dart';

class DramaList extends StatefulWidget {
  const DramaList({super.key});

  @override
  State<DramaList> createState() => _DramaListState();
}

class _DramaListState extends State<DramaList> {
  late Future<dynamic> _dramaData;

  static const MaxLoopNumber = 8;

  final List<DramaMeta> loop = [];
  final List<DramaMeta> trending = [];
  final List<DramaMeta> newList = [];
  final List<DramaMeta> recommend = [];

  @override
  void initState() {
    super.initState();
    _dramaData = fetchData();
  }

  Future<dynamic> fetchData() async {
    try {
      final result = await Request.postRequest(GET_DRAMA_CHANNEL, {});
      final res = result['response'] ?? {};
      if (res['loop'] is List) {
        for (var item in res['loop']) {
          if(loop.length < MaxLoopNumber){
            loop.add(DramaMeta.fromJson(item));
          }
        }
      }
      if (res['trending'] is List) {
        for (var item in res['trending']) {
          trending.add(DramaMeta.fromJson(item));
        }
      }
      if (res['new'] is List) {
        for (var item in res['new']) {
          newList.add(DramaMeta.fromJson(item));
        }
      }
      if (res['recommend'] is List) {
        for (var item in res['recommend']) {
          recommend.add(DramaMeta.fromJson(item));
        }
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _dramaData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final result = snapshot.data;

            if (result == null) {
              return const Center(
                child: Text('Data request failed'),
              );
            }

            return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      forceElevated: innerBoxIsScrolled,
                      leading: Container(),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 363.w,
                        margin: const EdgeInsets.only(bottom: 48),
                        child: LoopCarouselSlider(data: loop),
                      ),
                      DramaItemWrap(
                          isShow: trending.isNotEmpty,
                          title: 'Most trending 🔥',
                          child: TrendingList(data: trending)),
                      DramaItemWrap(
                        isShow: newList.isNotEmpty,
                        title: 'New release ',
                        child: NewDramaList(data: newList),
                      ),
                      DramaItemWrap(
                        isShow: recommend.isNotEmpty,
                        title: 'Recommended',
                        child: RecommendList(data: recommend),
                      ),
                    ],
                  ),
                ));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class DramaItemWrap extends StatelessWidget {
  const DramaItemWrap(
      {super.key,
      required this.isShow,
      required this.child,
      required this.title,
      this.isShrink = true});

  final Widget child;
  final String title;
  final bool isShrink;
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return isShow
        ? Container(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            padding: const EdgeInsets.all(16),
            child: Column(
              // mainAxisSize: isShrink ? MainAxisSize.min : MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 12.w),
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18),
                    )),
                child
              ],
            ))
        : const SizedBox.shrink();
  }
}

class TrendingList extends StatelessWidget {
  const TrendingList({super.key, this.data = const []});

  final List<DramaMeta> data;

  bool isTop(i) => i < 3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 294.w,
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 9 / 16,
            crossAxisCount: 3,
            mainAxisSpacing: 16.w,
            crossAxisSpacing: 12.w),
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < data.length; i++)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/drama_player',
                    arguments: {"dramaMeta": data[i], "order": 1});
              },
              child: SizedBox(
                child: Row(
                  children: [
                    DramaCover(
                      coverImg: Image(
                        image: NetworkImage(data[i].dramaCoverUrl!),
                        fit: BoxFit.cover,
                      ),
                      width: 68.w,
                      height: 90.w,
                      tlBadge: CoverBadge(
                        text: "${isTop(i) ? 'TOP' : ''}${i + 1}",
                        textColor: isTop(i)
                            ? topDramaBadgeBgColor['TextColor'] as Color
                            : defaultDramaBadge['TextColor'] as Color,
                        gradientColor: isTop(i)
                            ? topDramaBadgeBgColor['BgColor'] as Gradient
                            : defaultDramaBadge['BgColor'] as Gradient,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(left: 8.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DramaTitle(title: data[i].dramaTitle!),
                          Text(
                            formatNumber(data[i].dramaPlayTimes!),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

class NewDramaList extends StatelessWidget {
  const NewDramaList({
    super.key,
    required this.data,
  });

  final List<DramaMeta> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 181.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/drama_player',
                  arguments: {"dramaMeta": data[index], "order": 1});
            },
            child: Container(
              width: 100.w,
              margin: (index < (data.length - 1))
                  ? EdgeInsets.only(right: 16.w)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DramaCover(
                    coverImg: Image(
                      image: NetworkImage(data[index].dramaCoverUrl!),
                      fit: BoxFit.cover,
                    ),
                    height: 133.w,
                    blBadge: PlayCount(count: data[index].dramaPlayTimes!),
                    tlBadge: data[index].newRelease == true
                        ? const CoverBadge(
                            text: 'New',
                            gradientColor: LinearGradient(colors: [
                              Color.fromARGB(255, 254, 59, 211),
                              Color.fromARGB(255, 245, 0, 103)
                            ]))
                        : const SizedBox.shrink(),
                  ),
                  Container(
                    height: 40.w,
                    margin: const EdgeInsets.only(top: 8),
                    child: DramaTitle(title: data[index].dramaTitle!),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecommendList extends StatelessWidget {
  const RecommendList({
    super.key,
    required this.data,
  });

  final List<DramaMeta> data;

  @override
  Widget build(BuildContext context) {
    final List<List<DramaMeta>> dataByGroup = [];
    for (int i = 0; i < data.length; i += 2) {
      if (i + 1 < data.length) {
        dataByGroup.add([data[i], data[i + 1]]);
      } else {
        dataByGroup.add([data[i]]);
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (List<DramaMeta> row in dataByGroup)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: row.map((item) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/drama_player',
                            arguments: {"dramaMeta": item, "order": 1});
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            DramaCover(
                              coverImg: Image(
                                image: NetworkImage(item.dramaCoverUrl!),
                                fit: BoxFit.cover,
                              ),
                              width:
                                  (MediaQuery.of(context).size.width - 40.w) /
                                      2, // width - (padding + space)
                              blBadge: PlayCount(count: item.dramaPlayTimes!),
                              tlBadge: item.newRelease == true
                                  ? const CoverBadge(
                                      text: 'New',
                                      gradientColor: LinearGradient(colors: [
                                        Color.fromARGB(255, 254, 59, 211),
                                        Color.fromARGB(255, 245, 0, 103)
                                      ]))
                                  : const SizedBox.shrink(),
                            ),
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width - 40.w) /
                                      2,
                              height: 40.w,
                              margin: const EdgeInsets.only(top: 8),
                              child: DramaTitle(title: item.dramaTitle!),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
            ],
          ),
        )
      ],
    );
  }
}

class LoopCarouselSlider extends StatefulWidget {
  const LoopCarouselSlider({super.key, required this.data});

  final List<DramaMeta> data;

  @override
  State<LoopCarouselSlider> createState() => _LoopCarouselSliderState();
}

class _LoopCarouselSliderState extends State<LoopCarouselSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('my-widget-key'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage < 5) {
          _controller.stopAutoPlay();
        } else {
          _controller.startAutoPlay();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                  height: 347.0.w,
                  viewportFraction: 0.7,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayAnimationDuration: const Duration(seconds: 1),
                  autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              items: widget.data.map((item) {
                return Builder(builder: (BuildContext context) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(76, 255, 255, 255),
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.w),
                                child: Image(
                                  image: NetworkImage(item.dramaCoverUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            PlayNowButton(
                              id: item.dramaId!,
                              dramaMeta: item,
                            )
                          ],
                        )),
                  );
                });
              }).toList(),
            ),
          ),
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: Iterable<int>.generate(widget.data.length).map((index) {
                return Container(
                  width: _current == index ? 20.w : 12.w,
                  height: 4.w,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == index ? 0.9 : 0.4)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
