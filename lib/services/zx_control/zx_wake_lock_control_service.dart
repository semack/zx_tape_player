import 'package:wakelock/wakelock.dart';
import 'package:zx_tape_player/services/wake_lock_service.dart';

class ZxWakeLockControlService extends WakeLockControlService {
  @override
  Future start() async {
    await Wakelock.enable();
  }

  @override
  Future stop() async {
    await Wakelock.disable();
  }
}
