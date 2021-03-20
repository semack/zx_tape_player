import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:zx_tape_player/utils/extensions.dart';

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
          SpinKitThreeBounce(size: 16.0, color: HexColor('#AFB6BB')),
          SizedBox(
            height: 16.0,
          ),
          Text(
            loadingText,
            style: TextStyle(color: HexColor('#AFB6BB'), fontSize: 14.0),
          ),
        ]));
  }
}
