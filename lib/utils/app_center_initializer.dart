import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:zx_tape_player/utils/definitions.dart';

class AppCenterInitializer {
  AppCenterInitializer._();

  static Future register() async {
    await AppCenter.startAsync(
      appSecretAndroid: Definitions.appCenter_secret_Android,
      appSecretIOS: Definitions.appCenter_secret_iOS,
      enableDistribute: false,
    );
    await AppCenter.configureDistributeDebugAsync(enabled: false);
  }
}
