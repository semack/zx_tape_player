import 'dart:async';

import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:zx_tape_player/ui/widgets/cassette.dart';
import 'package:zx_tape_player/utils/extensions.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    var duration = 3;
    // skip annoying splash for debug mode
    // if (const String.fromEnvironment('DEBUG') != null) duration = 0;
    Timer(
        Duration(seconds: duration),
        () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
              return HomeScreen();
            })));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Expanded(
          child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Cassette(),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text('zx_tape_player',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 22, color: Colour('##E7ECED')))
                    .tr()),
          ],
        ),
      )),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
          child: Column(children: <Widget>[
            FutureBuilder<PackageInfo>(
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                var copyrightText = tr('copyright');
                if (snapshot.hasData) {
                  copyrightText += tr('version').format(
                      [snapshot.data.version, snapshot.data.buildNumber]);
                }
                return Text(copyrightText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, height: 1.8, color: Colour('#AFB6BB')));
              },
              future: PackageInfo.fromPlatform(),
            ),
          ]))
    ]));
  }
}
