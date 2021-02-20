import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class LoadingProgress extends StatelessWidget {
  LoadingProgress({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child:           Loading(indicator: BallPulseIndicator(), size: 30.0, color: Colour('#AFB6BB')),
      // child: Row(
      //   children: [
      //     Text(
      //       tr('loading'),
      //       style: TextStyle(
      //           fontSize: 14, color: Colour('#AFB6BB'), letterSpacing: -0.5),
      //       textAlign: TextAlign.center,
      //     ),
      //   ],
      // )
    );
  }
}
