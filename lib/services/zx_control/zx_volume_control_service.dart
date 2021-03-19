import 'dart:io';

import 'package:volume_controller/volume_controller.dart';
import 'package:zx_tape_player/services/volume_control_service.dart';
import 'package:zx_tape_player/utils/definitions.dart';

class ZxVolumeControlService extends VolumeControlService {
  var _hasSet = false;

  @override
  Future setOptimalVolume() async {
    if (_hasSet) return;
    var value = Definitions.optimalVolumeAndroid;
    if (Platform.isIOS) value = Definitions.optimalVolumeIOS;
    VolumeController.setVolume(value);
    _hasSet = true;
  }
}
