import 'package:flutter/material.dart';
import 'package:zx_tape_player/utils/extensions.dart';

enum SnackBarType { info, error }

class BarHelper {
  BarHelper._();

  static Future showSnackBar(
      {@required String message,
      @required BuildContext context,
      SnackBarType barType = SnackBarType.info,
      Duration duration = const Duration(seconds: 3)}) async {
    await Future.delayed(const Duration(), () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    });
    var backgroundColor = HexColor('#172434');
    if (barType == SnackBarType.error) backgroundColor = HexColor('#D9512D');
    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: backgroundColor,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
    await Future.delayed(const Duration(), () {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}
