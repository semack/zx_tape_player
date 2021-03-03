import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

class AppCenterInitializer {
  static const _appCenter_secret_iOS = 'b1cba03b-9d97-40bb-b013-d72470115b6e';
  static const _appCenter_secret_Android =
      '6677d8c4-a257-4f0c-bc39-00775b5f1daf';
  static const _appCenter_token_iOS =
      'f13adfc49d8526e49cf2d01b873f8d7a500579a7';
  static const _appCenter_token_Android =
      '8c20228bd26247a7c0fcbba088d5c3adbcdd9dd2';

  AppCenterInitializer._();

  static Future initialize() async {
    await AppCenter.startAsync(
      appSecretAndroid: _appCenter_secret_Android,
      appSecretIOS: _appCenter_secret_iOS,
      enableDistribute: false,
    );
    await AppCenter.configureDistributeDebugAsync(enabled: false);
  }
}
