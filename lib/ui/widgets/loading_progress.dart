import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class LoadingProgress extends StatelessWidget {
  LoadingProgress({Key key}) : super(key: key);

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
            tr("loading"),
            style: TextStyle(color: Colour('#AFB6BB'), fontSize: 12.0),
          ),
        ]));
  }
}
