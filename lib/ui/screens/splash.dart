
import 'dart:async';

import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _rotationController;

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    super.initState();
    _rotationController.forward();
    var duration = 3;

    // skip annoying splash for debug mode
    if (const String.fromEnvironment('DEBUG') != null) duration = 0;
    Timer(
        Duration(seconds: duration),
        () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
              return HomeScreen();
            })));
  }

  @override
  void dispose() {
    _rotationController.stop();
    _rotationController.dispose();
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
                Container(
                  width: 260,
                  height: 189,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash/logo.png'),
                        fit: BoxFit.fill,
                      ),
                      shape: BoxShape.rectangle),
                  child: Row(
                      children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 55, left: 60),
                          child: RotationTransition(
                            turns: Tween(begin: 1.9, end: 0.0)
                                .animate(_rotationController),
                            child:
                                Image.asset('assets/images/splash/spool.png'),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 55, left: 30),
                          child: RotationTransition(
                        turns: Tween(begin: 1.9, end: 0.0)
                            .animate(_rotationController),
                        child: Image.asset('assets/images/splash/spool.png'),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("ZX TAPE PLAYER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'ZxSpectrum',
                        fontSize: 18.5,
                        color: Colour('##E7ECED')))),
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
                var copyrightText =
                    "© 2021 Andriy S'omak\r\nAll rights reserved\r\n";
                if (snapshot.hasData) {
                  var version = snapshot.data.version;
                  copyrightText += "version $version";
                }
                return Text(copyrightText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'ZxSpectrum',
                        fontSize: 10,
                        height: 1.8,
                        color: Colour('#AFB6BB')));
              },
              future: PackageInfo.fromPlatform(),
            ),
          ]))
    ]));
  }
}
