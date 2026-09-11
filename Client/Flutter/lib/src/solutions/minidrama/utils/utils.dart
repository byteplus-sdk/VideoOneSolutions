import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    await deviceInfo.androidInfo;
    return const AndroidId().getId(); // unique ID on Android
  } else if (Platform.isMacOS) {
    var macDeviceInfo = await deviceInfo.macOsInfo;
    return macDeviceInfo.systemGUID; // unique ID on iOS
  }
  return null;
}

String formatSeconds(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;
  String formattedHours = hours.toString().padLeft(2, '0');
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
  if (hours == 0) {
    return '$formattedMinutes:$formattedSeconds';
  }
  return '$formattedHours:$formattedMinutes:$formattedSeconds';
}
