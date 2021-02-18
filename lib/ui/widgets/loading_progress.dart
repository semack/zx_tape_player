import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoadingProgress extends StatelessWidget {
  LoadingProgress({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        tr('loading'),
        style: TextStyle(
            fontSize: 14, color: Colour('#AFB6BB'), letterSpacing: -0.5),
        textAlign: TextAlign.center,
      ),
    );
  }
}
