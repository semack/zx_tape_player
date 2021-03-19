import 'dart:io';

import 'package:flutter_mute/flutter_mute.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zx_tape_player/services/silence_control_service.dart';

class ZxSilenceControlService implements SilenceControlService {
  RingerMode _ringerMode;

  @override
  Future start() async {
    if (!Platform.isAndroid || _ringerMode != null) return;
    var isAccessGranted = await FlutterMute.isNotificationPolicyAccessGranted;
    if (isAccessGranted) {
      _ringerMode = await FlutterMute.getRingerMode();
      await FlutterMute.setRingerMode(RingerMode.Silent);
    } else {
      var prefs = await SharedPreferences.getInstance();
      var initialized = prefs.getBool('dndAccessInitialized');
      if (initialized == null || !initialized) {
        await prefs.setBool('dndAccessInitialized', true);
        await FlutterMute.openNotificationPolicySettings();
      }
    }
  }

  @override
  Future stop() async {
    if (_ringerMode == null) return;
    await FlutterMute.setRingerMode(_ringerMode);
    _ringerMode = null;
  }
}
