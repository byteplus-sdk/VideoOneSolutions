import 'dart:async';

import 'package:flutter/material.dart';

enum AdWatchStatus {
  enough,
  notEnough,
}

class AdPlayerView extends StatefulWidget {
  static const routeName = '/ad_player';

  const AdPlayerView({super.key,});

  @override
   createState() => _AdPlayerViewState();
}


class _AdPlayerViewState extends State {
  late AdWatchStatus adWatchEnough = AdWatchStatus.notEnough;
  

  Widget _buildTobBar(context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 44,
        padding: const EdgeInsets.only(left: 16, right: 16),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              width: 67,
              height: 32,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.54),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.08), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Ad',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const VerticalDivider(
                    color: Colors.grey,
                    width: 1,
                  ),
                  Image.asset('assets/minidrama/common/mute.png'),
                ],
              )),
          Container(
              width: 67,
              height: 32,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.54),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.08), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [
                    Container(
                      margin: const EdgeInsets.only(right: 3),
                      child: CountDown(
                        count: 10,
                        onFinish: () {
                          setState(() {
                            adWatchEnough = AdWatchStatus.enough;
                            Navigator.of(context).pop(adWatchEnough);
                          });
                        },
                      ),
                    ),
                    const Text(
                      's',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(adWatchEnough);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                ],
              ))
        ]));
  }

  Widget _buildTip() {
    return Container(
      width: 250,
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.7),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Image.asset('assets/minidrama/common/lock_ad.png'),
          ),
          const Text(
            'Congratulations on unlocking 1 episode',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                decoration: TextDecoration.none,
                height: 1.5),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildAdContainer(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                  'https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/cocacola.gif',
                  fit: BoxFit.cover)),
          adWatchEnough == AdWatchStatus.enough ? Center(child: _buildTip()): const SizedBox.shrink(), 
          Positioned(
            top: 60,
            left: 0,
            child: _buildTobBar(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAdContainer(context);
  }
}

class CountDown extends StatefulWidget {
  const CountDown({super.key, required this.count, this.onFinish});
  final int count;
  final void Function()? onFinish;


  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  Timer? _timer;
  late int count;

  @override
  void initState() {
    super.initState();
    setState(() {
      count = widget.count;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (count > 0) {
          count--;
        } else {
          widget.onFinish?.call();
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      count.toString(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        decoration: TextDecoration.none,
      ),
      textAlign: TextAlign.center,
    );
  }
}
