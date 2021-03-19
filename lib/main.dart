import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get_it/get_it.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/services/silence_control_service.dart';
import 'package:zx_tape_player/services/volume_control_service.dart';
import 'package:zx_tape_player/services/wake_lock_service.dart';
import 'package:zx_tape_player/services/zx_api/zxapi_service.dart';
import 'package:zx_tape_player/services/zx_control/zx_silence_control_service.dart';
import 'package:zx_tape_player/services/zx_control/zx_volume_control_service.dart';
import 'package:zx_tape_player/services/zx_control/zx_wake_lock_control_service.dart';
import 'package:zx_tape_player/ui/home_screen.dart';
import 'package:zx_tape_player/ui/player_screen.dart';
import 'package:zx_tape_player/utils/app_center_initializer.dart';
import 'package:zx_tape_player/utils/definitions.dart';

import 'ui/search_screen.dart';
import 'ui/splash_screen.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
  FlutterStatusbarcolor.setNavigationBarColor(Colors.black);
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  getIt.registerLazySingleton<BackendService>(() => ZxApiService());
  getIt.registerLazySingleton<SilenceControlService>(() => ZxSilenceControlService());
  getIt.registerLazySingleton<WakeLockControlService>(() => ZxWakeLockControlService());
  getIt.registerLazySingleton<VolumeControlService>(() => ZxVolumeControlService());

  await AppCenterInitializer.initialize();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('cs', 'CZ'),
        Locale('da', 'DK'),
        Locale('es', 'ES'),
        Locale('it', 'IT'),
        Locale('nl', 'NL'),
        Locale('pt', 'PT'),
        Locale('ru', 'RU'),
        Locale('sk', 'SK'),
        Locale('uk', 'UA')
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: ZxTapePlayer()));
}

class ZxTapePlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: Definitions.appTitle,
        theme: ThemeData(
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colour('#546B7F'),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'ZxSpectrum',
        ),
        home: SplashScreen(),
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
          SearchScreen.routeName: (context) => SearchScreen(),
          PlayerScreen.routeName: (context) => PlayerScreen(),
        });
  }
}
