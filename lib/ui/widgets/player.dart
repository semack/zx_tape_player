import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zx_tape_player/models/player_args.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_player/utils/platform.dart';
import 'package:zx_tape_to_wav/zx_tape_to_wav.dart';

class Player extends StatefulWidget {
  PlayerArgsTypeEnum _sourceType;
  List<String> _files;
  AudioPlayer _audioPlayer;

  Player(
      {Key key,
      PlayerArgsTypeEnum sourceType = PlayerArgsTypeEnum.network,
      List<String> files,
      AudioPlayer audioPlayer})
      : super(key: key) {
    _files = files;
    _sourceType = sourceType;
    _audioPlayer = audioPlayer;
  }

  @override
  _PlayerState createState() {
    return _PlayerState();
  }
}

class _PlayerState extends State<Player> {
  int _currentFileIndex = 0;
  double _filePosition = 0;
  bool _isPreparation = false;
  bool _paused = false;

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
                //constraints: BoxConstraints.expand(),
                //padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                //width: MediaQuery.of(context).size.width,
                height: 80.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colour('#172434'),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                  child: CarouselSlider(
                    items: widget._files
                        .map((fileName) => Container(
                              padding: EdgeInsets.all(12.0),
                              child: Center(
                                  child: Text(
                                basename(fileName),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                                maxLines: 3,
                              )),
                            ))
                        .toList(),
                    options: CarouselOptions(
                        scrollPhysics: widget._files.length < 2 ||
                                widget._audioPlayer.playing ||
                                _paused
                            ? const NeverScrollableScrollPhysics()
                            : const AlwaysScrollableScrollPhysics(),
                        autoPlay: false,
                        enlargeCenterPage: false,
                        aspectRatio: 2.0,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentFileIndex = index;
                          });
                        }),
                  ),
                )),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget._files.length > 1 &&
                        !(widget._audioPlayer.playing || _paused)
                    ? widget._files.map((f) {
                        int index = widget._files.indexOf(f);
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentFileIndex == index
                                ? Colour('#D8DCE0')
                                : Colour('546B7F'),
                          ),
                        );
                      }).toList()
                    : [
                        Container(
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 2.0),
                        )
                      ]),
          ]),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('00:00/12:00',
                        style: TextStyle(
                            fontSize: 12.0, color: Colour('#B1B8C1'))),
                    Text('12:00',
                        style: TextStyle(
                            fontSize: 12.0, color: Colour('#B1B8C1'))),
                  ])),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: SliderTheme(
              data: SliderThemeData(
                  activeTrackColor: Colors.white,
                  // Colour('#546B7F'),
                  inactiveTrackColor: Colour('#546B7F'),
                  overlappingShapeStrokeColor: Colour('#546B7F'),
                  trackShape: CustomTrackShape(),
                  thumbColor: Colors.white),
              child: Slider(
                value: _filePosition,
                onChanged: (value) => setState(() {
                  _filePosition = value;
                }),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () {
                  _paused = false;
                  widget._audioPlayer.stop();
                  widget._audioPlayer.play();
                  setState(() {});
                },
                color: Colors.transparent,
                child: Icon(
                  Icons.refresh_rounded,
                  color: widget._audioPlayer.playing || _paused
                      ? Colors.white
                      : Colour('#546B7F'),
                  size: 40.0,
                ),
                padding: EdgeInsets.all(10.0),
                shape: CircleBorder(),
              ),
              Container(
                width: 90.0,
                child: Center(child:
              _isPreparation
                  ? Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: Colour('#28384C'),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Center( child:SizedBox(
                        height: 40.0,
                        width: 40.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                            backgroundColor: Colors.transparent,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      )))
                  : FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () => _play(),
                      color: Colour('#28384C'),
                      child: Icon(
                        widget._audioPlayer.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 50.0,
                      ),
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(5.0),
                    ),),),
              FlatButton(
                onPressed: () {
                  _paused = false;
                  widget._audioPlayer.stop();
                  setState(() {});
                },
                //elevation: 0,
                color: Colors.transparent,
                child: Icon(
                  Icons.stop_rounded,
                  color: widget._audioPlayer.playing || _paused
                      ? Colors.white
                      : Colour('#546B7F'),
                  size: 40.0,
                ),
                padding: EdgeInsets.all(10.0),
                shape: CircleBorder(),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Future _play() async {
    var tempFile =
        '%s/zxtape.tmp.wav'.format([(await getTemporaryDirectory()).path]);
    var file = File(tempFile);
    try {
      if (widget._audioPlayer.playing) {
        widget._audioPlayer.pause();
        _paused = true;
      } else {
        if (!_paused) {
          setState(() {
            _isPreparation = true;
          });
          var url = fixToSecUrl(widget._files[_currentFileIndex]);
          var source = await BackendService.downloadTape(url);
          var tape = await ZxTape.create(source);
          var wav = await tape.toWavBytes();
          await file.writeAsBytes(wav);
          await widget._audioPlayer.setFilePath(tempFile);
          await widget._audioPlayer.setVolume(0.75);
        }
        widget._audioPlayer.play();
      }
    } catch (e) {
      if (await file.exists()) await file.delete();
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          e.toString(),
          style: TextStyle(color: Colors.white),
        ),
      );
      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      Scaffold.of(this.context).showSnackBar(snackBar);
    }
    setState(() {
      _isPreparation = false;
    });
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
