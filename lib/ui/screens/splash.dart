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
    Timer(
        Duration(seconds: 3),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colour('#546B7F'),
      body: Center(
        // child: AnimatedContainer(),
      ),
    );
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
