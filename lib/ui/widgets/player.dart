import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_player/utils/platform.dart';
import 'package:zx_tape_to_wav/zx_tape_to_wav.dart';

class Player extends StatefulWidget {
  Player({Key key, List<String> files}) : super(key: key) {
    _files = files;
  }

  List<String> _files;

  @override
  _PlayerState createState() {
    return _PlayerState();
  }
}

class _PlayerState extends State<Player> {
  final _player = AudioPlayer();
  int _currentFileIndex = 0;
  double _filePosition = 0;
  bool _isPlaying = false;

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
                        enableInfiniteScroll: widget._files.length > 1,
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
                children: widget._files.length > 1
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
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    onPressed: () {},
                    //elevation: 0,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colour('#546B7F'),
                      size: 50.0,
                    ),
                    padding: EdgeInsets.all(10.0),
                    shape: CircleBorder(),
                  ),
                  FlatButton(
                    onPressed: () => _play(),
                    color: Colour('#28384C'),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 50.0,
                    ),
                    padding: EdgeInsets.all(10.0),
                    shape: CircleBorder(),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        _isPlaying = false;
                      });
                    },
                    //elevation: 0,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.stop_rounded,
                      color: Colour('#546B7F'),
                      size: 50.0,
                    ),
                    padding: EdgeInsets.all(10.0),
                    shape: CircleBorder(),
                  ),
                ],
              )),
        ],
      ),
    ));
  }

  Future _play() async {
    setState(() {
      _isPlaying = true;
    });
    try {
      var url = fixToSecUrl(widget._files[_currentFileIndex]);
      var source = await BackendService.downloadTape(url);
      var tape = await ZxTape.create(source);
      var wav = await tape.toWavBytes();
      var tempFile = '%s/%s.wav'.format([
        (await getTemporaryDirectory()).path,
        basename(widget._files[_currentFileIndex])
      ]);
      var file = File(tempFile);
      await file.writeAsBytes(wav);
      await _player.setFilePath(tempFile);
      await _player.setVolume(0.75);
      _player.play();
    } catch (e) {
      var z = e;
    }
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
