import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zx_tape_player/utils/extensions.dart';

import 'custom_track_shape.dart';
import 'hidden_thumb_component_shape.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    @required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;
  SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(this.context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
              thumbShape: HiddenThumbComponentShape(),
              activeTrackColor: Colors.white30,
              inactiveTrackColor: HexColor('#546B7F'),
              trackShape: CustomTrackShape(),
              disabledInactiveTrackColor: HexColor('#546B7F')),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: widget.bufferedPosition.inMilliseconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
              trackShape: CustomTrackShape(),
              disabledThumbColor: Colors.white,
              disabledInactiveTrackColor: Colors.transparent),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        Positioned(
          left: 0.0,
          top: 0.0,
          child: FutureBuilder(builder: (context, snapshot) {
            return Text(_getTimeString(_position),
                style: TextStyle(fontSize: 12.0, color: HexColor('#B1B8C1')));
          }),
        ),
        Positioned(
            right: 0.0,
            top: 0.0,
            child: Text(
                "%s/%s".format([
                  _getTimeString(_remaining),
                  _getTimeString(widget.duration)
                ]),
                style: TextStyle(
                  fontSize: 12.0,
                  color: HexColor('#B1B8C1'),
                ))),
      ],
    );
  }

  String _getTimeString(Duration time) {
    return RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
            .firstMatch("$time")
            ?.group(1) ??
        "$time";
  }

  Duration get _position => _dragValue != null
      ? Duration(milliseconds: _dragValue.round())
      : widget.position;

  Duration get _remaining => widget.duration - widget.position;
}
