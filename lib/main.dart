import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zx_tape_player/services/abstract/backend_service.dart';
import 'package:zx_tape_player/services/zxapi_service.dart';
import 'package:zx_tape_player/ui/home_screen.dart';
import 'package:zx_tape_player/ui/player_screen.dart';
import 'package:zx_tape_player/utils/app_center_initializer.dart';

import 'ui/search_screen.dart';
import 'ui/splash_screen.dart';

final AudioPlayer audioPlayer = AudioPlayer();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GetIt getIt = GetIt.instance;

void main() async {
  getIt.registerLazySingleton<BackendService>(() => ZxApiService());
  WidgetsFlutterBinding.ensureInitialized();
  await AppCenterInitializer.initialize();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('da', 'DK'),
        Locale('it', 'IT'),
        Locale('nl', 'NL'),
        Locale('ru', 'RU'),
        Locale('uk', 'UA')
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: new ZxTapePlayer()));
}

class ZxTapePlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: tr('app_title'),
        theme: ThemeData(
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colour('#546B7F'),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'ZxSpectrum',
        ),
        home: SplashScreen(),
        navigatorObservers: [
          routeObserver
        ],
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
          SearchScreen.routeName: (context) => SearchScreen(),
          PlayerScreen.routeName: (context) => PlayerScreen(),
        });
  }
}
