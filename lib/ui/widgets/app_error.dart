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
          FlatButton(
            color: Colour('#68B8DF'),
            textColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
            onPressed: action,
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ]));
  }
}
