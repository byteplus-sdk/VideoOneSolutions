import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/widgets/series_modal/series_modal.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/drama_service.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum UnlockType {
  unlockAll,
  unlockPartial,
}

class SeriesPayModal extends StatefulWidget {
  const SeriesPayModal(
      {super.key, required this.dramaMeta, required this.dramaService});
  final DramaMeta dramaMeta;
  final DramaService dramaService;
  @override
  State<SeriesPayModal> createState() => _SeriesPayModalState();
}

//  剧集付费modal
class _SeriesPayModalState extends State<SeriesPayModal> {
  static const int price = 5;
  static const double discount = 0.6;
  static const int UnlockMaxNumber = 3;

  late int selectIndex = 0;
  late String totalPrice = '';
  late int vipDramaLength = 0;
  late List vipIdList = [];

  @override
  void initState() {
    super.initState();
    calcSeriesDramaVip();
  }

  calcSeriesDramaVip() {
    setState(() {
      var list = widget.dramaService.dramaList;
      var vipList = list.where((element) {
        if (element.videoMeta.vip) {
          vipIdList.add(element.videoMeta.vid);
          return true;
        }
        return false;
      });

      vipDramaLength = vipList.length;

      var dramaNumber = vipDramaLength > UnlockMaxNumber ? UnlockMaxNumber : vipDramaLength;
      var mode1Price = (dramaNumber * price).toDouble().toStringAsFixed(1);
      var mode2Price = (vipDramaLength * price * discount).toStringAsFixed(1);

      if (vipList.length > UnlockMaxNumber) {
        selectIndex = 1;
        totalPrice = mode2Price;
      } else {
        totalPrice = mode1Price;
      }
    });
  }

  UnlockType unlockType = UnlockType.unlockPartial;

  onClose() {
    Navigator.pop(context);
  }

  Future<void> onPayFor() async {
    context.loaderOverlay.show();
    await Future.delayed(const Duration(seconds: 2));
    context.loaderOverlay.hide();
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop(unlockType);
  }

  Widget _buildPayTitle() {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          const Expanded(
            child: Text('Unlock multiple episodes',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color.fromRGBO(12, 13, 14, 1))),
          ),
          GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(217, 217, 217, 1),
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 18,
                  weight: 700,
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildSeriesDetail() {
    Widget buildDesText(text, isAllow) {
      var style = const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color.fromRGBO(22, 24, 35, 1));
      return Container(
        margin: const EdgeInsets.only(right: 15),
        child: Row(
          children: [
            Container(
                margin: const EdgeInsets.only(right: 2),
                child: Image.asset(
                    'assets/minidrama/common/${isAllow ? 'allow' : 'not_allow'}.png')),
            Text(text, style: style)
          ],
        ),
      );
    }

    return Container(
        margin: const EdgeInsets.only(top: 15, bottom: 15),
        child: Row(children: [
          buildDesText('Permanent viewing', true),
          buildDesText('No refund', false),
        ]));
  }

  Widget _buildPaySelect() {
    var dramaNumber = vipDramaLength > UnlockMaxNumber ? UnlockMaxNumber : vipDramaLength;
    var mode1Price = (dramaNumber * price).toDouble().toStringAsFixed(1);
    var mode2Price = (vipDramaLength * price * discount).toStringAsFixed(1);
    var originalPrice = (vipDramaLength * price).toStringAsFixed(1);

    void onSelect(index) {
      setState(() {
        selectIndex = index;
        totalPrice = index == 0 ? mode1Price : mode2Price;
        unlockType =
            index == 0 ? UnlockType.unlockPartial : UnlockType.unlockAll;
      });
    }

    Widget buildSelectButton(child, index) {
      return GestureDetector(
          onTap: () => onSelect(index),
          child: Container(
            width: 155.5,
            height: 66,
            padding: const EdgeInsets.only(left: 10),
            margin: const EdgeInsets.only(right: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: selectIndex == index
                    ? const Color.fromRGBO(254, 44, 85, 0.04)
                    : const Color.fromRGBO(22, 24, 35, 0.01),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                    color: selectIndex == index
                        ? const Color.fromRGBO(254, 44, 85, 1)
                        : const Color.fromRGBO(22, 24, 35, 0.01),
                    width: 1)),
            child: child,
          ));
    }

    Widget buildText(mode) {
      const style = TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Color.fromRGBO(22, 24, 35, 1));
      if (mode == 1) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dramaNumber episodes',
              style: style,
            ),
            Text(
              'USD $mode1Price',
              style: style,
            ),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text(
                'All episodes',
                style: style,
              ),
              Container(
                width: 31,
                height: 16,
                margin: const EdgeInsets.only(left: 5),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(254, 44, 85, 1),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: const Text(
                  '60%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ]),
            Row(
              children: [
                Text(
                  'USD $mode2Price',
                  style: style,
                ),
                Text(
                  '(USD$originalPrice)',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Color.fromRGBO(22, 24, 35, 0.75),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(22, 24, 35, 0.75),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildSelectButton(buildText(1), 0),
        buildSelectButton(buildText(2), 1)
      ],
    );
  }

  Widget _buildPayInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(children: [
        SeriesInfo(
          dramaMeta: widget.dramaMeta,
          dramaService: widget.dramaService,
          titleTextColor: const Color.fromRGBO(22, 24, 35, 1),
          descriptionColor: const Color.fromRGBO(22, 24, 35, 0.75),
        ),
        Divider(
          height: 0.5,
          color: Colors.grey.shade200,
        ),
        _buildSeriesDetail(),
        _buildPaySelect()
      ]),
    );
  }

  Widget _buildPayButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 44,
      margin: const EdgeInsets.only(top: 15, bottom: 15),
      child: TextButton(
          onPressed: onPayFor,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return const Color.fromRGBO(254, 44, 85, 1);
            }),
            shape: WidgetStateProperty.resolveWith((states) {
              return const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)));
            }),
          ),
          child: Text(
            'Pay for \$$totalPrice',
            style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 1),
                fontWeight: FontWeight.w500,
                fontSize: 16),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 249, 241, 1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      height: 375,
      child: Column(
        children: [
          _buildPayTitle(),
          Expanded(child: SingleChildScrollView(child: _buildPayInfo())),
          _buildPayButton(),
        ],
      ),
    );
  }
}
