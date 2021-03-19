import 'package:app_center_bundle_sdk/app_center_bundle_sdk.dart';

class AppCenterInitializer {
  static const _secret_iOS = 'b1cba03b-9d97-40bb-b013-d72470115b6e';
  static const _secret_Android = '6677d8c4-a257-4f0c-bc39-00775b5f1daf';

  AppCenterInitializer._();

  static Future initialize() async {
    await AppCenter.startAsync(
            appSecretAndroid: _secret_Android,
            appSecretIOS: _secret_iOS,
            disableAutomaticCheckForUpdate: true)
        .then(
            (value) => AppCenter.configureDistributeDebugAsync(enabled: false));
  }
}
