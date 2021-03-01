import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zx_tape_player/models/args/player_args.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_to_wav/zx_tape_to_wav.dart';

class TapePlayer extends StatefulWidget {
  final List<String> files;
  final AudioPlayer audioPlayer;

  TapePlayer(
      {Key key,
      PlayerArgsTypeEnum sourceType = PlayerArgsTypeEnum.network,
      @required this.files,
      @required this.audioPlayer})
      : super(key: key) {}

  @override
  _TapePlayerState createState() {
    return _TapePlayerState();
  }
}

class _TapePlayerState extends State<TapePlayer> {
  int _currentFileIndex = 0;

  AudioPlayer get _player => widget.audioPlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 292.0,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      width: MediaQuery.of(context).size.width,
      color: Colour('#3B4E63'),
      child: Column(
        children: [
          Column(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                width: double.infinity,
                height: 80.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colour('#172434'),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                  child: CarouselSlider(
                    items: widget.files
                        .map((fileName) => Container(
                              padding: EdgeInsets.all(12.0),
                              child: Center(
                                  child: Text(
                                basename(fileName),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.0),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              )),
                            ))
                        .toList(),
                    options: CarouselOptions(
                        scrollPhysics:
                            // widget.files.length < 2 ||
                            widget.audioPlayer.playing
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                        autoPlay: false,
                        enlargeCenterPage: false,
                        aspectRatio: 2.0,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) async {
                          setState(() {
                            _currentFileIndex = index;
                          });
                        }),
                  ),
                )),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    // widget.files.length > 1
                    //     ?
                    widget.files.map((f) {
                  int index = widget.files.indexOf(f);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentFileIndex == index
                          ? Colour('#D8DCE0')
                          : Colour('546B7F'),
                    ),
                  );
                }).toList()
                // : [
                //     Container(
                //       height: 8.0,
                //       margin: EdgeInsets.symmetric(
                //           vertical: 16.0, horizontal: 2.0),
                //     )
                //   ]
                ),
          ]),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            // vertical: 8.0),
            child: StreamBuilder<Duration>(
              stream: _player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<PositionData>(
                  stream: Rx.combineLatest2<Duration, Duration, PositionData>(
                      _player.positionStream,
                      _player.bufferedPositionStream,
                      (position, bufferedPosition) =>
                          PositionData(position, bufferedPosition)),
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(Duration.zero, Duration.zero);
                    var position = positionData.position ?? Duration.zero;
                    if (position > duration) {
                      position = duration;
                    }
                    var bufferedPosition =
                        positionData.bufferedPosition ?? Duration.zero;
                    if (bufferedPosition > duration) {
                      bufferedPosition = duration;
                    }
                    return SeekBar(
                      duration: duration,
                      position: position,
                      bufferedPosition: bufferedPosition,
                      onChangeEnd: (newPosition) {
                        _player.seek(newPosition);
                      },
                    );
                  },
                );
              },
            ),
          ),
          ControlButtons(
              player: _player, tapeUri: widget.files[_currentFileIndex]),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     FlatButton(
          //       onPressed: () {
          //         _paused = false;
          //         widget.audioPlayer.stop();
          //         widget.audioPlayer.play();
          //         setState(() {});
          //       },
          //       color: Colors.transparent,
          //       child: Icon(
          //         Icons.refresh_rounded,
          //         color: widget.audioPlayer.playing || _paused
          //             ? Colors.white
          //             : Colour('#546B7F'),
          //         size: 40.0,
          //       ),
          //       padding: EdgeInsets.all(10.0),
          //       shape: CircleBorder(),
          //     ),
          //     Container(
          //       width: 90.0,
          //       child: Center(
          //         child: _isPreparation
          //             ? Container(
          //                 width: 60.0,
          //                 height: 60.0,
          //                 decoration: BoxDecoration(
          //                   color: Colour('#28384C'),
          //                   borderRadius: BorderRadius.all(
          //                     Radius.circular(30),
          //                   ),
          //                 ),
          //                 child: Center(
          //                     child: SizedBox(
          //                   height: 40.0,
          //                   width: 40.0,
          //                   child: CircularProgressIndicator(
          //                       strokeWidth: 2.0,
          //                       backgroundColor: Colors.transparent,
          //                       valueColor: AlwaysStoppedAnimation<Color>(
          //                           Colors.white)),
          //                 )))
          //             : FlatButton(
          //                 materialTapTargetSize:
          //                     MaterialTapTargetSize.shrinkWrap,
          //                 onPressed: () => _play(),
          //                 color: Colour('#28384C'),
          //                 child: Icon(
          //                   widget.audioPlayer.playing
          //                       ? Icons.pause_rounded
          //                       : Icons.play_arrow_rounded,
          //                   color: Colors.white,
          //                   size: 50.0,
          //                 ),
          //                 shape: CircleBorder(),
          //                 padding: EdgeInsets.all(5.0),
          //               ),
          //       ),
          //     ),
          //     FlatButton(
          //       onPressed: () {
          //         _paused = false;
          //         widget.audioPlayer.stop();
          //         setState(() {});
          //       },
          //       //elevation: 0,
          //       color: Colors.transparent,
          //       child: Icon(
          //         Icons.stop_rounded,
          //         color: widget.audioPlayer.playing || _paused
          //             ? Colors.white
          //             : Colour('#546B7F'),
          //         size: 40.0,
          //       ),
          //       padding: EdgeInsets.all(10.0),
          //       shape: CircleBorder(),
          //     ),
          //     StreamBuilder<double>(
          //       stream: _player.speedStream,
          //       builder: (context, snapshot) => IconButton(
          //         icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
          //             style: TextStyle(fontWeight: FontWeight.bold)),
          //         onPressed: () {
          //           _showSliderDialog(
          //             context: context,
          //             title: tr('adjust_speed'),
          //             divisions: 12,
          //             min: 1,
          //             max: 4,
          //             stream: _player.speedStream,
          //             onChanged: _player.setSpeed,
          //           );
          //         },
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    ));
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;

  PositionData(this.position, this.bufferedPosition);
}

class ControlButtons extends StatefulWidget {
  ControlButtons({Key key, @required this.player, @required this.tapeUri})
      : super(key: key);
  final AudioPlayer player;
  final String tapeUri;

  @override
  _ControlButtonsState createState() {
    return _ControlButtonsState();
  }
}

class _ControlButtonsState extends State<ControlButtons> {
  AudioPlayer get player => widget.player;

  String get tapeUri => widget.tapeUri;
  bool _isLoading = false;
  String wavFileName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.volume_up),
          onPressed: () {
            _showSliderDialog(
              context: context,
              title: tr("adjust_volume"),
              valueSuffix: "%",
              divisions: 20,
              min: 0,
              max: 100,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                  icon: Icon(Icons.play_arrow),
                  iconSize: 64.0,
                  onPressed: () async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      wavFileName = '%s/%s.wav'.format([
                        (await getTemporaryDirectory()).path,
                        new DateTime.now().millisecondsSinceEpoch
                      ]);
                      var file = File(wavFileName);
                      try {
                        await BackendService.downloadTape(this.tapeUri)
                            .then((source) => ZxTape.create(source))
                            .then((tape) =>
                                tape.toWavBytes(amplifySoundSignal: true))
                            .then((wav) => file.writeAsBytes(wav))
                            .then((file) => player.setFilePath(file.path))
                            .then((value) async {
                          setState(() {
                            _isLoading = false;
                          });
                          await player.play();
                        });
                      } finally {
                        if (!player.playing && await file.exists())
                          await file.delete();
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    } catch (error) {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          error.toString(),
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  });
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices.first),
              );
            }
          },
        ),
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              _showSliderDialog(
                context: context,
                title: tr("adjust_speed"),
                valueSuffix: "x",
                divisions: 6,
                min: 1,
                max: 4,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}

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
            inactiveTrackColor: Colour('#546B7F'),
            trackShape: CustomTrackShape(),
          ),
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
            thumbColor: Colour(Colors.white),
            trackShape: CustomTrackShape(),
          ),
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
                style: TextStyle(fontSize: 12.0, color: Colour('#B1B8C1')));
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
                  color: Colour('#B1B8C1'),
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

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      TextPainter labelPainter,
      RenderBox parentBox,
      SliderThemeData sliderTheme,
      TextDirection textDirection,
      double value,
      double textScaleFactor,
      Size sizeWithOverflow}) {}
}

_showSliderDialog({
  BuildContext context,
  String title,
  int divisions,
  double min,
  double max,
  String valueSuffix = '',
  Stream<double> stream,
  ValueChanged<double> onChanged,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colour('#3B4E63'),
      title: Text(title,
          textAlign: TextAlign.center,
          style: TextStyle(wordSpacing: 0.3, color: Colors.white)),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => Container(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: TextStyle(
                      wordSpacing: 0.5, fontSize: 24.0, color: Colors.white)),
              SizedBox(
                height: 16.0,
              ),
              SliderTheme(
                  data: SliderThemeData(
                      activeTickMarkColor: Colors.white,
                      activeTrackColor: Colors.white,
                      inactiveTickMarkColor: Colors.white,
                      inactiveTrackColor: Colour('#546B7F'),
                      thumbColor: Colors.white),
                  child: Slider(
                    divisions: divisions,
                    min: min,
                    max: max,
                    value: snapshot.data ?? 1.0,
                    onChanged: onChanged,
                  )),
            ],
          ),
        ),
      ),
    ),
  );
}
