import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zx_tape_player/ui/home_screen.dart';
import 'package:zx_tape_player/ui/player_screen.dart';

import 'ui/search_screen.dart';
import 'ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US')],
        path: 'assets/translations', // <-- change patch to your
        fallbackLocale: Locale('en', 'US'),
        child: new ZxTapePlayer()),
  );
}

class ZxTapePlayer extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Zx Tape Player',
        theme: ThemeData(
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colour('#546B7F'),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          //fontFamily: 'Roboto',
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
