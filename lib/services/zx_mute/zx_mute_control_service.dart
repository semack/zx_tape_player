import 'dart:io';

import 'package:flutter_mute/flutter_mute.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zx_tape_player/services/mute_control_service.dart';

class ZxMuteControlService implements MuteControlService {
  RingerMode _ringerMode;

  @override
  Future mute({bool state = true}) async {
    if (!Platform.isAndroid) return;
    if (state)
      await _mute();
    else
      await _unmute();
  }

  Future _mute() async {
    if (_ringerMode != null) return;
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

  Future _unmute() async {
    if (_ringerMode == null) return;
    await FlutterMute.setRingerMode(_ringerMode);
    _ringerMode = null;
  }
}
