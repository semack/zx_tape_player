import 'dart:async';

import 'package:colour/colour.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer(
    //     Duration(seconds: 3),
    //         () => Navigator.of(context).pushReplacement(MaterialPageRoute(
    //         builder: (BuildContext context) => HomeScreen())));
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
                Image.asset('assets/splash-logo.png', width: 260),
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
              padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
              child: Column(children: <Widget>[
                Text(
                    "© 2021 Andriy S'omak\r\nAll rights reserved\r\nVersion 1.0",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'ZxSpectrum',
                        fontSize: 9,
                        color: Colour('#AFB6BB'))),
              ]))
        ]));
  }
}

// class AfterSplash extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//           title: new Text("Welcome In SplashScreen Package"),
//           automaticallyImplyLeading: false
//       ),
//       body: new Center(
//         child: new Text("Done!",
//           style: new TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 30.0
//           ),),
//
//       ),
//     );
//   }
// }
