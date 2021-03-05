import 'dart:io';
import 'dart:typed_data';

import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/models/application/software_model.dart';
import 'package:zx_tape_player/models/enums/file_location.dart';
import 'package:zx_tape_player/services/abstract/backend_service.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_to_wav/zx_tape_to_wav.dart';

class ControlButtons extends StatefulWidget {
  ControlButtons({Key key, @required this.player, @required this.file})
      : super(key: key);
  final AudioPlayer player;
  final FileModel file;

  @override
  _ControlButtonsState createState() {
    return _ControlButtonsState();
  }
}

class _ControlButtonsState extends State<ControlButtons> {
  AudioPlayer get player => widget.player;

  FileModel get _file => widget.file;
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
              valueSuffix: "",
              divisions: 20,
              min: 0,
              max: 1,
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
                        Uint8List bytes;
                        if (_file.location == FileLocation.remote)
                          bytes = await getIt<BackendService>()
                              .downloadTape(_file.url);
                        else if (_file.location == FileLocation.file)
                          bytes = await File(_file.url).readAsBytes();
                        else
                          throw ArgumentError('Unrecognized file location');

                        await ZxTape.create(bytes)
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
