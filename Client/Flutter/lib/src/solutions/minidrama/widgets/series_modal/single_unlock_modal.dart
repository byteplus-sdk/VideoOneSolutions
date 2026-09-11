import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/drama_service.dart';

enum LockSelect {
  unlockSingle,
  unlockAll,
}

class SingleUnLockModal extends StatelessWidget {
  const SingleUnLockModal(
      {super.key, required this.dramaMeta, required this.dramaService});

  final DramaMeta dramaMeta;
  final DramaService dramaService;

  Widget _buildModalContainer(BuildContext context) {
    return Container(
        width: 240,
        height: 230,
        decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 249, 241, 1),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text(
                    'For free to 1 episode',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color.fromRGBO(81, 32, 12, 1)),
                  ),
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '1',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 36,
                              color: Color.fromRGBO(254, 44, 85, 1)),
                        ),
                        Text('Episode',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color.fromRGBO(254, 44, 85, 1)))
                      ]),
                ),
                Container(
                  height: 36,
                  margin: const EdgeInsets.only(
                    top: 20,
                  ),
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () =>
                          {Navigator.of(context).pop(LockSelect.unlockSingle)},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromRGBO(254, 44, 85, 1)),
                        shape: WidgetStateProperty.all(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)))),
                      ),
                      child: const Text('Watch an advertising video',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white))),
                ),
                Container(
                  height: 36,
                  margin: const EdgeInsets.only(
                    top: 12,
                  ),
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(LockSelect.unlockAll);
                      },
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)))),
                          side: WidgetStateProperty.all(const BorderSide(
                              color: Color.fromRGBO(254, 44, 85, 1),
                              width: 1))),
                      child: const Text('Unlock all episodes',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color.fromRGBO(254, 44, 85, 1)))),
                ),
              ],
            ),
            Positioned(
                width: 100,
                height: 80,
                top: -65,
                left: 55,
                child: Image.asset('assets/minidrama/common/lock_video.png')),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(12),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
      children: [_buildModalContainer(context)],
    );
  }
}
