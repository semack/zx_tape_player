import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_center_bundle_sdk/app_center_bundle_sdk.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/models/enums/file_location.dart';
import 'package:zx_tape_player/models/position_data.dart';
import 'package:zx_tape_player/models/software_model.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/seek_bar.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_to_wav/zx_tape_to_wav.dart';

class TapePlayer extends StatefulWidget {
  final List<FileModel> files;

  TapePlayer({Key key, @required this.files}) : super(key: key);

  @override
  _TapePlayerState createState() {
    return _TapePlayerState();
  }
}

class _TapePlayerState extends State<TapePlayer> {
  _TapePlayerBloc _bloc;

  // int _currentFileIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _bloc = _TapePlayerBloc(widget.files);
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
      padding: //EdgeInsets.fromLTRB(0, 16, 0, 0), //
          EdgeInsets.symmetric(vertical: 16.0),
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
                    child: StreamBuilder<PlayerState>(
                      stream: _bloc.player.playerStateStream,
                      builder: (context, snapshot) {
                        // final playerState = snapshot.data;
                        return CarouselSlider(
                          items: widget.files
                              .map((file) => Container(
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
                                  // (playerState != null &&
                                  //             playerState.playing &&
                                  //             playerState.processingState !=
                                  //                 ProcessingState.completed) ||
                                  widget.files.length == 1
                                      ? const NeverScrollableScrollPhysics()
                                      : const AlwaysScrollableScrollPhysics(),
                              autoPlay: false,
                              enlargeCenterPage: false,
                              aspectRatio: 2.0,
                              viewportFraction: 1.0,
                              onPageChanged: (index, reason) async {
                                setState(() {
                                  _bloc.currentFileIndex = index;
                                });
                              }),
                        );
                      },
                    ))),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.files.map((f) {
                  int index = widget.files.indexOf(f);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _bloc.currentFileIndex == index
                          ? Colour('#D8DCE0')
                          : Colour('#546B7F'),
                    ),
                  );
                }).toList()),
          ]),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            // vertical: 8.0),
            child: StreamBuilder<Duration>(
              stream: _bloc.player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<PositionData>(
                  stream: Rx.combineLatest2<Duration, Duration, PositionData>(
                      _bloc.player.positionStream,
                      _bloc.player.bufferedPositionStream,
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
                        _bloc.player.seek(newPosition);
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

  Widget _buildControlButtons(BuildContext context) {
    return StreamBuilder<PreparationModel>(
        stream: _bloc.preparationStream,
        builder: (context, snapshot) {
          var isLoading = false;
          if (snapshot != null && snapshot.hasData) {
            if (snapshot.data.state == PreparationState.Error &&
                _bloc.currentModel == snapshot.data.model) {
              final snackBar = SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  tr('error_converting_tape_file'),
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
              Future.delayed(const Duration(), () {
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            } else {
              isLoading = snapshot.data.state != PreparationState.Ready;
              Future.delayed(const Duration(), () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              });
            }
          }
          return StreamBuilder<PlayerState>(
            stream: _bloc.player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing ?? false;
              return Center(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_up_rounded),
                    color: Colors.white,
                    onPressed: () {
                      _showSliderDialog(
                        context: context,
                        title: tr("adjust_volume"),
                        valueSuffix: "",
                        divisions: 20,
                        min: 0,
                        max: 1,
                        stream: _bloc.player.volumeStream,
                        onChanged: _bloc.player.setVolume,
                      );
                    },
                  ),
                  SizedBox(width: 46.0),
                  // IconButton(
                  //   color: Colors.white,
                  //   disabledColor: Colour('#546B7F'),
                  //   icon: Icon(Icons.replay_rounded),
                  //   iconSize: 30.0,
                  //   onPressed:
                  //       playing || processingState == ProcessingState.completed
                  //           ? _bloc.replay
                  //           : null,
                  // ),
                  SizedBox(width: 16.0),
                  Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Colour('#28384C'),
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: FutureBuilder(builder: (context, snaphot) {
                      if (
                          // processingState == ProcessingState.loading ||
                          //     processingState == ProcessingState.buffering ||
                          isLoading) {
                        return Center(
                            child: SizedBox(
                          height: 40.0,
                          width: 40.0,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              backgroundColor: Colors.transparent,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                        ));
                      } else if (!playing) {
                        return IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.play_arrow_rounded),
                            iconSize: 40.0,
                            onPressed: _bloc.play);
                      } else if (processingState != ProcessingState.completed) {
                        return IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.pause_rounded),
                          iconSize: 40.0,
                          onPressed: _bloc.pause,
                        );
                      } else {
                        return IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.replay_rounded),
                            iconSize: 40.0,
                            onPressed: _bloc.replay);
                      }
                    }),
                  ),
                  SizedBox(width: 16.0),
                  IconButton(
                    color: Colors.white,
                    disabledColor: Colour('#546B7F'),
                    icon: Icon(Icons.stop_rounded),
                    iconSize: 40.0,
                    onPressed: (playing ||
                            (_bloc.player.position != null &&
                                _bloc.player.position.inMilliseconds > 0))
                        ? _bloc.stop
                        : null,
                  ),
                  SizedBox(width: 16.0),
                  StreamBuilder<double>(
                    stream: _bloc.player.speedStream,
                    builder: (context, snapshot) => IconButton(
                      color: Colors.white,
                      icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        _showSliderDialog(
                          context: context,
                          title: tr("adjust_speed"),
                          valueSuffix: "x",
                          divisions: 6,
                          min: 1,
                          max: 4,
                          stream: _bloc.player.speedStream,
                          onChanged: _bloc.player.setSpeed,
                        );
                      },
                    ),
                  ),
                  // FutureBuilder(builder: (context, snapshot) {
                  //   return null;
                  // }),
                ],
              ));
            },
          );
        });
  }
}

enum PreparationState { Downloading, Converting, Ready, Error }

class ProgressModel {
  final double percent;
  final FileModel fileModel;

  ProgressModel(this.fileModel, this.percent);
}

class PreparationModel {
  final PreparationState state;
  final String message;
  final FileModel model;

  PreparationModel(this.state, this.model, {this.message});
}

class _TapePlayerBloc {
  final List<FileModel> files;
  int _currentFileIndex;

  int get currentFileIndex => _currentFileIndex;

  FileModel get currentModel => files[_currentFileIndex];

  set currentFileIndex(int index) {
    if (_currentFileIndex != index) {
      var oldPlayer = _player;
      _player = AudioPlayer();
      _currentFileIndex = index;
      _getWavFilePath(_currentFileIndex)
          .then((wavFilePath) => _player.setFilePath(wavFilePath));
      oldPlayer.dispose();
    }
  }

  AudioPlayer get player => _player;
  AudioPlayer _player = AudioPlayer();
  final _backendService = getIt<BackendService>();

  StreamController _preparationController =
      StreamController<PreparationModel>();

  StreamSink<PreparationModel> get preparationSink =>
      _preparationController.sink;

  Stream<PreparationModel> get preparationStream =>
      _preparationController.stream;

  StreamController _progressController = StreamController<ProgressModel>();

  StreamSink<ProgressModel> get progressSink => _progressController.sink;

  Stream<ProgressModel> get progressStream => _progressController.stream;

  _TapePlayerBloc(this.files) {
    if (files.length > 0) currentFileIndex = 0;
  }

  Future play() async {
    _player.play();
  }

  Future stop() async {
    _player.stop();
    currentFileIndex = _currentFileIndex;
  }

  Future pause() async {
    _player.pause();
  }

  Future replay() async {
    _player.seek(Duration.zero, index: _player.effectiveIndices.first);
  }

  Future<String> _getWavFilePath(int index) async {
    var model = files[index];
    try {
      var tapePath =
          Definitions.tapeDir.format([(await getTemporaryDirectory()).path]);
      var dir = await new Directory(tapePath).create(recursive: true);
      var wavFileName =
          Definitions.wafFilePath.format([dir.path, basename(model.url)]);
      var file = File(wavFileName);
      if (!await file.exists()) {
        _preparationController.sink
            .add(PreparationModel(PreparationState.Downloading, model));
        Uint8List bytes;
        if (model.location == FileLocation.remote)
          bytes = await _backendService.downloadTape(model.url);
        else if (model.location == FileLocation.file)
          bytes = await File(model.url).readAsBytes();
        else
          throw ArgumentError('Unrecognized file location');
        _preparationController.sink
            .add(PreparationModel(PreparationState.Converting, model));
        await ZxTape.create(bytes)
            .then((tape) => tape.toWavBytes(
                frequency: Definitions.wavFrequency,
                progress: (percent) {
                  var data = ProgressModel(model, percent);
                  _progressController.sink.add(data);
                }))
            .then((wav) => file.writeAsBytes(wav));
      }
      _preparationController.sink
          .add(PreparationModel(PreparationState.Ready, model));
      return wavFileName;
    } catch (e) {
      _preparationController.sink.add(PreparationModel(
          PreparationState.Error, model,
          message: e.toString()));
      await AppCenter.trackEventAsync('error', e);
    }
    return '';
  }

  void dispose() {
    _player?.dispose();
    _progressController?.close();
    _preparationController?.close();
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
