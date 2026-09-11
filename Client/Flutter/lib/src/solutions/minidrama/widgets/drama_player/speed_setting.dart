import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';

class SpeedSetting extends StatefulWidget {
  const SpeedSetting({super.key, required this.videoController});

  final VideoController videoController;
  @override
  State<SpeedSetting> createState() => _SpeedSettingState();
}

class _SpeedSettingState extends State<SpeedSetting> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.videoController,
        builder: (context, _) {
          return SafeArea(
            child: Column(
              children: [
                SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        'Playback speed',
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    )),
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (context, idx) {
                    return GestureDetector(
                      onTap: () {
                        widget.videoController
                            .setPlaybackSpeed(PlaySpeed.values[idx])
                            .then((value) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        color: widget.videoController.speed ==
                                PlaySpeed.values[idx]
                            ? Colors.white.withOpacity(0.12)
                            : Colors.transparent,
                        height: 48,
                        child: Center(
                            child: Text('${PlaySpeed.values[idx].speed}x',
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white))),
                      ),
                    );
                  },
                  itemCount: PlaySpeed.values.length,
                )),
              ],
            ),
          );
        });
  }
}
