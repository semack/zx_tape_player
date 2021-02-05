
import 'dart:async';

import 'package:colour/colour.dart';
import 'package:flutter/material.dart';

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
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    super.initState();
    _rotationController.forward();
    Timer(
        Duration(seconds: 3),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen())));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colour('#546B7F'),
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
                    mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 55, left: 60),
                          child: RotationTransition(
                            turns: Tween(begin: 1.4, end: 0.0)
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
                            turns: Tween(begin: 1.4, end: 0.0)
                                .animate(_rotationController),
                            child:
                            Image.asset('assets/images/splash/spool.png'),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Text("ZX TAPE PLAYER",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'ZxSpectrum',
                            fontSize: 18,
                            color: Colour('##E7ECED')))),
              ],
            ),
          )),
          Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: Column(children: <Widget>[
                Text(
                    "© 2021 Andriy S'omak\r\nAll rights reserved\r\nVersion 1.0",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'ZxSpectrum',
                        fontSize: 12,
                        height: 1.8,
                        color: Colour('#AFB6BB'))),
              ]))
        ]));
  }
}
