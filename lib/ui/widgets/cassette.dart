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

  bool get _animated => widget._animated;
  int get _durationSec => widget._durationSec;
  final double _rotationRatio = 0.63;

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: Duration(seconds: widget._durationSec),
      vsync: this,
    );
    super.initState();
    if (widget._animated) _rotationController.forward();
  }

  @override
  void didUpdateWidget(covariant Cassette oldWidget) {
    _rotationController.duration = Duration(seconds: _durationSec);
    if (_animated && !_rotationController.isAnimating)
      _rotationController.forward();
    else if (!_animated && _rotationController.isAnimating)
      _rotationController.stop();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
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
      child: Stack(children: [
        Positioned(
          top: 55, left: 60,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: _rotationRatio * _durationSec).animate(_rotationController),
            child: Image.asset('assets/images/splash/spool.png'),
          ),),
        Positioned(
          top: 55, right: 60,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: _rotationRatio * _durationSec).animate(_rotationController),
            child: Image.asset('assets/images/splash/spool.png'),
          ),),
      ]),
    );
  }
}
