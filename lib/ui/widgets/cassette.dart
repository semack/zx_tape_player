import 'package:flutter/material.dart';

class Cassette extends StatefulWidget {
  bool _animated;
  int _durationSec;

  Cassette({Key key, bool animated = true, int durationSec = 3})
      : super(key: key) {
    _animated = animated;
    _durationSec = durationSec;
  }

  @override
  _CassetteState createState() {
    return _CassetteState();
  }
}

class _CassetteState extends State<Cassette>
    with SingleTickerProviderStateMixin {
  AnimationController _rotationController;

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: Duration(seconds: widget._durationSec),
      vsync: this,
    );
    super.initState();
    if (widget._animated)
      _rotationController.forward();
  }

  @override
  void didUpdateWidget(covariant Cassette oldWidget) {
    _rotationController.duration = Duration(seconds: widget._durationSec);
    if (widget._animated && !_rotationController.isAnimating)
      _rotationController.forward();
    else if (!widget._animated && _rotationController.isAnimating)
      _rotationController.stop();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _rotationController.stop();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 189,
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash/logo.png'),
            fit: BoxFit.fill,
          ),
          shape: BoxShape.rectangle),
      child: Row(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 55, left: 60),
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.9).animate(_rotationController),
                child: Image.asset('assets/images/splash/spool.png'),
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 55, left: 30),
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.9).animate(_rotationController),
                child: Image.asset('assets/images/splash/spool.png'),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
