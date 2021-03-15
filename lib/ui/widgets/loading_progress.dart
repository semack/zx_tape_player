import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
          SpinKitThreeBounce(size: 16.0, color: Colour('#AFB6BB')),
          SizedBox(
            height: 16.0,
          ),
          Text(
            loadingText,
            style: TextStyle(color: Colour('#AFB6BB'), fontSize: 14.0),
          ),
        ]));
  }
}
