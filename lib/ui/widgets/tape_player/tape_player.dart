import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/models/application/position_data.dart';
import 'package:zx_tape_player/models/application/software_model.dart';
import 'package:zx_tape_player/models/enums/file_location.dart';
import 'package:zx_tape_player/services/abstract/backend_service.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/seek_bar.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_to_wav/zx_tape_to_wav.dart';

class TapePlayer extends StatefulWidget {
  final List<FileModel> files;
  final AudioPlayer audioPlayer;

  TapePlayer({Key key, @required this.files, @required this.audioPlayer})
      : super(key: key);

  @override
  _TapePlayerState createState() {
    return _TapePlayerState();
  }
}

class _TapePlayerState extends State<TapePlayer> {
  _TapePlayerBloc _bloc = _TapePlayerBloc();
  int _currentFileIndex = 0;

  AudioPlayer get _player => widget.audioPlayer;
  List<FileModel> get _files => widget.files;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          height: 292.0,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          width: MediaQuery
              .of(context)
              .size
              .width,
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
                            .map((file) =>
                            Container(
                              padding: EdgeInsets.all(12.0),
                              child: Center(
                                  child: Text(
                                    basename(file.url),
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
                      stream: Rx.combineLatest2<Duration,
                          Duration,
                          PositionData>(
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
              _buildControlButtons(context),
            ],
          ),
        ));
  }

  @override
  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.volume_up),
          onPressed: () {
            _showSliderDialog(
              context: context,
              title: tr("adjust_volume"),
              valueSuffix: "",
              divisions: 20,
              min: 0,
              max: 1,
              stream: _player.volumeStream,
              onChanged: _player.setVolume,
            );
          },
        ),
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
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
                      var wavFilePath = await _bloc._getWavPath(_files[_currentFileIndex]);
                      _player.setFilePath(wavFilePath);
                      _player.play();
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
                onPressed: _player.pause,
              );
            } else {
              return IconButton(
                icon: Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () =>
                    _player.seek(Duration.zero,
                        index: _player.effectiveIndices.first),
              );
            }
          },
        ),
        StreamBuilder<double>(
          stream: _player.speedStream,
          builder: (context, snapshot) =>
              IconButton(
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
                    stream: _player.speedStream,
                    onChanged: _player.setSpeed,
                  );
                },
              ),
        ),
      ],
    );
  }
}

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


class _TapePlayerBloc {
  Future<String> _getWavPath(FileModel model) async {
    var wavFileName = '%s/%s.wav'.format([
      (await getTemporaryDirectory()).path,
      new DateTime.now().millisecondsSinceEpoch
    ]);
    var file = File(wavFileName);
    Uint8List bytes;
    if (model.location == FileLocation.remote)
      bytes = await getIt<BackendService>()
          .downloadTape(model.url);
    else if (model.location == FileLocation.file)
      bytes = await File(model.url).readAsBytes();
    else
      throw ArgumentError('Unrecognized file location');

    await ZxTape.create(bytes)
        .then((tape) =>
        tape.toWavBytes(amplifySoundSignal: true))
        .then((wav) => file.writeAsBytes(wav));
    return wavFileName;
  }

  dispose() {
  }
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
    builder: (context) =>
        AlertDialog(
          backgroundColor: Colour('#3B4E63'),
          title: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(wordSpacing: 0.3, color: Colors.white)),
          content: StreamBuilder<double>(
            stream: stream,
            builder: (context, snapshot) =>
                Container(
                  height: 100.0,
                  child: Column(
                    children: [
                      Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                          style: TextStyle(
                              wordSpacing: 0.5,
                              fontSize: 24.0,
                              color: Colors.white)),
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

