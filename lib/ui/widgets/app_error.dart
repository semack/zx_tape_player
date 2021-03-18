import 'package:colour/colour.dart';
import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  final String text;

  final Function action;

  final buttonText;

  AppError(
      {Key key,
      @required this.text,
      @required this.buttonText,
      @required this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          SizedBox(
            height: 32.0,
          ),
          TextButton(
            child: Text(buttonText, style: TextStyle(fontSize: 14.0)),
            style: TextButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              backgroundColor: Colour('#68B8DF'),
              padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0)),
              ),
            ),
            onPressed: action,
          ),
        ]));
  }
}
