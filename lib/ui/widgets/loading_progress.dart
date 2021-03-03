import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class LoadingProgress extends StatelessWidget {
  final String loadingText;

  LoadingProgress({Key key, @required this.loadingText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Loading(
              indicator: BallPulseIndicator(),
              size: 30.0,
              color: Colour('#AFB6BB')),
          SizedBox(
            height: 5.0,
          ),
          Text(
            loadingText,
            style: TextStyle(color: Colour('#AFB6BB'), fontSize: 12.0),
          ),
        ]));
  }
}
