import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_center_bundle_sdk/app_center_bundle_sdk.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/models/software_model.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/services/silence_control_service.dart';
import 'package:zx_tape_player/services/volume_control_service.dart';
import 'package:zx_tape_player/services/wake_lock_service.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/models/converter_computation_data.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/models/position_data.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/models/progress_model.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/models/tape_player_data.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/seek_bar.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_to_wav/zx_tape_to_wav.dart';

class TapePlayer extends StatefulWidget {
  final SoftwareModel software;

  TapePlayer({Key key, @required this.software}) : super(key: key);

  @override
  _TapePlayerState createState() {
    return _TapePlayerState();
  }
}

class _TapePlayerState extends State<TapePlayer> {
  _TapePlayerBloc _bloc;

  @override
  void initState() {
    _bloc = _TapePlayerBloc(widget.software);
    super.initState();
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
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
        backgroundColor: HexColor('#3B4E63'),
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
                        inactiveTrackColor: HexColor('#546B7F'),
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

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            height: 268.0,
            padding: //EdgeInsets.fromLTRB(0, 16, 0, 0), //
                EdgeInsets.symmetric(vertical: 16.0),
            width: MediaQuery.of(context).size.width,
            color: HexColor('#3B4E63'),
            child: StreamBuilder<PlayerState>(
                stream: _bloc.player.playerStateStream,
                builder: (context, snapshot) {
                  var playerState = snapshot.data;
                  return StreamBuilder<TapePlayerData>(
                      stream: _bloc.tapePlayerStream,
                      builder: (context, snapshot) {
                        var tapePlayerData = snapshot.data;
                        final tapeLoading =
                            tapePlayerData?.state == TapePlayerState.Loading;
                        return Column(
                          children: [
                            Column(children: [
                              Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  width: double.infinity,
                                  height: 80.0,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: HexColor('#172434'),
                                        borderRadius:
                                            BorderRadius.circular(3.5),
                                      ),
                                      child: CarouselSlider(
                                        items: _bloc.files
                                            .map((filePath) => Container(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Center(
                                                      child: Text(
                                                    basename(filePath),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.0),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                  )),
                                                ))
                                            .toList(),
                                        options: CarouselOptions(
                                            scrollPhysics: _bloc
                                                            .player.position !=
                                                        Duration.zero ||
                                                    _bloc.files.length == 1 ||
                                                    tapeLoading
                                                ? const NeverScrollableScrollPhysics()
                                                : const AlwaysScrollableScrollPhysics(),
                                            autoPlay: false,
                                            enlargeCenterPage: false,
                                            aspectRatio: 2.0,
                                            viewportFraction: 1.0,
                                            initialPage: _bloc.currentFileIndex,
                                            onPageChanged:
                                                (index, reason) async {
                                              _bloc.currentFileIndex = index;
                                            }),
                                      ))),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _bloc.files.map((filePath) {
                                    int index = _bloc.files.indexOf(filePath);
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _bloc.currentFileIndex == index
                                            ? HexColor('#D8DCE0')
                                            : HexColor('#546B7F'),
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
                                  final duration =
                                      snapshot.data ?? Duration.zero;
                                  return StreamBuilder<PositionData>(
                                      stream: Rx.combineLatest2<Duration,
                                              Duration, PositionData>(
                                          _bloc.player.positionStream,
                                          _bloc.player.bufferedPositionStream,
                                          (position, bufferedPosition) =>
                                              PositionData(
                                                  position, bufferedPosition)),
                                      builder: (context, snapshot) {
                                        final positionData = snapshot.data ??
                                            PositionData(
                                                Duration.zero, Duration.zero);
                                        var position = positionData.position ??
                                            Duration.zero;
                                        if (position > duration) {
                                          position = duration;
                                        }
                                        var bufferedPosition =
                                            positionData.bufferedPosition ??
                                                Duration.zero;
                                        if (bufferedPosition > duration) {
                                          bufferedPosition = duration;
                                        }
                                        return SeekBar(
                                            duration: duration,
                                            position: position,
                                            bufferedPosition: bufferedPosition,
                                            onChangeEnd: (newPosition) {
                                              _bloc.player.seek(newPosition);
                                            });
                                      });
                                },
                              ),
                            ),
                            _buildControlButtons(
                                context, tapePlayerData, playerState),
                          ],
                        );
                      });
                })));
  }

  Widget _buildControlButtons(BuildContext context,
      TapePlayerData tapePlayerData, PlayerState playerState) {
    if (tapePlayerData != null) {
      if (tapePlayerData.state == TapePlayerState.Error &&
          _bloc.filePath == tapePlayerData.filePath) {
        final snackBar = SnackBar(
          backgroundColor: HexColor('#D9512D'),
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
        Future.delayed(const Duration(), () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        });
      }
    }

    final processingState = playerState?.processingState;
    final playing = playerState?.playing ?? false;
    final tapeLoading = tapePlayerData?.state == TapePlayerState.Loading;

    return Center(
        child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
        SizedBox(width: 24.0),
        Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: HexColor('#28384C'),
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: FutureBuilder(builder: (context, snapshot) {
            if (tapeLoading) {
              return Center(
                  child: SizedBox(
                height: 40.0,
                width: 40.0,
                child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
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
        SizedBox(width: 24.0),
        IconButton(
          color: Colors.white,
          disabledColor: HexColor('#546B7F'),
          icon: Icon(Icons.stop_rounded),
          iconSize: 40.0,
          onPressed: _bloc.player.position != Duration.zero ? _bloc.stop : null,
        ),
      ],
    ));
  }
}

class _TapePlayerBloc {
  final SoftwareModel software;

  List<String> get files => software.tapeFiles;
  int _currentFileIndex;
  AudioPlayer _player = AudioPlayer(handleInterruptions: false);
  final _backendService = getIt<BackendService>();
  final _wakeUpService = getIt<WakeLockControlService>();
  final _muteControlService = getIt<SilenceControlService>();
  final _volumeControlService = getIt<VolumeControlService>();

  int get currentFileIndex => _currentFileIndex;

  String get filePath => files[_currentFileIndex];

  AudioPlayer get player => _player;

  StreamController _tapePlayerController = StreamController<TapePlayerData>();

  StreamSink<TapePlayerData> get tapePlayerSink => _tapePlayerController.sink;

  Stream<TapePlayerData> get tapePlayerStream => _tapePlayerController.stream;

  StreamController _progressController =
      StreamController<LoadingProgressData>();

  StreamSink<LoadingProgressData> get progressSink => _progressController.sink;

  Stream<LoadingProgressData> get progressStream => _progressController.stream;

  _TapePlayerBloc(this.software) {
    currentFileIndex = software.currentFileIndex;
  }

  static Future _getAndConvertImage(ConverterComputationData data) async {
    Uint8List bytes;
    if (data.isRemote)
      bytes = await data.backendService.downloadTape(data.filePath);
    else
      bytes = await File(data.filePath).readAsBytes();
    var tape = await ZxTape.create(bytes);
    var wav = await tape.toWavBytes(
        frequency: Definitions.wavFrequency,
        progress: (percent) {
          var sink = LoadingProgressData(data.filePath, percent);
          data.controller.sink.add(sink);
        });
    await data.file.writeAsBytes(wav);
  }

  Future<bool> _prepareTapeForPlay({bool force = true}) async {
    var filePath = files[_currentFileIndex];
    try {
      var wavPath =
          Definitions.tapeDir.format([(await getTemporaryDirectory()).path]);
      var dir = await new Directory(wavPath).create(recursive: true);
      var wavFileName =
          Definitions.wafFilePath.format([dir.path, basename(filePath)]);
      var file = File(wavFileName);
      if (!await file.exists()) {
        if (!force) {
          await _player.setAsset('assets/sounds/empty.wav');
          return false;
        }
        _tapePlayerController.sink
            .add(TapePlayerData(TapePlayerState.Loading, filePath));
        var convertModel = ConverterComputationData(filePath, software.isRemote,
            file, _backendService, _progressController);
        await compute(_getAndConvertImage, convertModel);
        _tapePlayerController.sink
            .add(TapePlayerData(TapePlayerState.Idle, filePath));
      }
      await _player.setFilePath(wavFileName);
      return true;
    } catch (e) {
      _tapePlayerController.sink.add(TapePlayerData(
          TapePlayerState.Error, filePath,
          message: e.toString()));
      await AppCenter.trackEventAsync('error', e);
    }
    return false;
  }

  void _cleanWavCache() {
    getTemporaryDirectory().then((dir) {
      var tapePath = Definitions.tapeDir.format([dir.path]);
      return Directory(tapePath);
    }).then((dir) async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });
  }

  set currentFileIndex(int index) {
    _currentFileIndex = index;
    _prepareTapeForPlay(force: false);
    _tapePlayerController.sink.add(
        TapePlayerData(TapePlayerState.IndexChanged, files[_currentFileIndex]));
  }

  Future play() async {
    if (_player.position == Duration.zero) {
      if (await _prepareTapeForPlay()) await _takeControl();
    }
    await _player.play();
  }

  Future stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    await _looseControl();
  }

  Future pause() async {
    await _player.pause();
  }

  Future replay() async {
    await _player.seek(Duration.zero, index: _player.effectiveIndices.first);
  }

  void dispose() {
    _looseControl()
        .then((value) => _cleanWavCache())
        .then((value) => _player?.dispose())
        .then((value) => _progressController?.close())
        .then((value) => _tapePlayerController?.close());
  }

  Future _takeControl() async {
    await _volumeControlService.setOptimalVolume();
    await _muteControlService.start();
    await _wakeUpService.start();
  }

  Future _looseControl() async {
    await _muteControlService.stop();
    await _wakeUpService.stop();
  }
}
