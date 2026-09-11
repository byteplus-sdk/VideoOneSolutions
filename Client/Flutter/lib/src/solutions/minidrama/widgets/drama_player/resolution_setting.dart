import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/video_sdk/video_controller.dart';

class ResolutionSetting extends StatefulWidget {
  const ResolutionSetting({super.key, required this.videoController});

  final VideoController videoController;
  @override
  State<ResolutionSetting> createState() => _ResolutionSettingState();
}

class _ResolutionSettingState extends State<ResolutionSetting> {
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
                        '清晰度',
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
                            .setCurrentResolution(
                                widget.videoController.resTypes[idx])
                            .then((value) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        color: widget.videoController.resolution ==
                                widget.videoController.resTypes[idx]
                            ? Colors.white.withOpacity(0.12)
                            : Colors.transparent,
                        height: 48,
                        child: Center(
                            child: Text(
                                '${VideoResolution.getVideoResolutionByName(widget.videoController.resTypes[idx].name)}',
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white))),
                      ),
                    );
                  },
                  itemCount: widget.videoController.resTypes.length,
                )),
              ],
            ),
          );
        });
  }
}
