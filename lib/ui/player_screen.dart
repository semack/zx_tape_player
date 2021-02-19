import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:zx_tape_player/models/item_dto.dart';
import 'package:zx_tape_player/models/player_args.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/ui/widgets/loading_progress.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key key}) : super(key: key);
  static const routeName = '/player';

  @override
  _PlayerScreenState createState() {
    return _PlayerScreenState();
  }
}

class _PlayerScreenState extends State<PlayerScreen> {
  ItemDto _item;
  List<String> _files;
  PlayerArgs _args;
  bool _isLoading = true;
  double _filePosition = 0.0;
  CarouselController _carouselController = new CarouselController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(this.context).settings.arguments;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    //_loadData();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _args.title,
          overflow: TextOverflow.fade,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: 60.0,
        backgroundColor: Colour('#28384C'),
      ),
      body: _isLoading
          ? LoadingProgress()
          : Column(
              children: <Widget>[
                _buildInfoWidget(context),
                _files.length > 0
                    ? _buildPlayerWidget(context)
                    : _buildNoFilesWidget(context)
              ],
            ),
    );
  }

  String _getFistLine() {
    var result = _item.source.originalYearOfRelease != null
        ? _item.source.originalYearOfRelease.toString()
        : '';
    if (_item.source.genre != null) {
      if (result.isNotEmpty) result += ' • ';
      result += _item.source.genre;
    }
    return result;
  }

  Widget _buildNoFilesWidget(BuildContext context) {
    return Container(
        color: Colour('#3B4E63'),
        height: 50.0,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            tr('no_tapes'),
            style: TextStyle(
                fontSize: 14, color: Colour('#AFB6BB'), letterSpacing: -0.5),
          ),
        ));
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Expanded(
        // child: Container(
        //     width: MediaQuery.of(context).size.width,
        //     decoration: BoxDecoration(
        //       image: DecorationImage(
        //         image: _item.source.screens.length > 0
        //             ? NetworkImage(Definitions.contentBaseUrl +
        //                 _item.source.screens[0].url)
        //             : null,
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //     child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
            //color: Colors.black.withOpacity(0.7),
            color: Colour('#172434'),
            child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFistLine(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colour('#B1B8C1'),
                            letterSpacing: 0.3,
                            fontSize: 12.0),
                      ),
                      SizedBox(height: 14.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/search/like.png',
                              width: 12.0, height: 12.0),
                          SizedBox(width: 5),
                          Text(
                            _item.source.score.votes != null
                                ? _item.source.score.votes.toString()
                                : tr('na'),
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.3,
                                fontSize: 12.0),
                          ),
                          SizedBox(width: 20),
                          Image.asset('assets/images/search/star.png',
                              width: 12.0, height: 12.0),
                          SizedBox(width: 5),
                          Text(
                            _item.source.score.score != null &&
                                    _item.source.score.score > 0
                                ? _item.source.score.score.toString()
                                : tr('na'),
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.3,
                                fontSize: 12.0),
                          ),
                          SizedBox(width: 20),
                          Text(
                            _item.source.originalPrice != null &&
                                    _item.source.originalPrice.amount != null
                                ? _item.source.originalPrice.amount
                                : '',
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.3,
                                fontSize: 12.0),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            _item.source.originalPrice != null && _item.source.originalPrice.currency != null &&
                                    _item.source.originalPrice.currency
                                            .replaceAll('/', '') !=
                                        'NA'
                                ? _item.source.originalPrice.currency
                                : '',
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.3,
                                fontSize: 12.0),
                          ),
                        ],
                      ),
                      _item.source.remarks != null
                          ? SizedBox(height: 24.0)
                          : SizedBox.shrink(),
                      Row(children: [
                        Expanded(
                            child: _item.source.remarks != null
                                ? Text(
                                    _item.source.remarks.removeAllHtmlTags(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                        height: 1.4,
                                        fontSize: 14.0),
                                    maxLines: 256,
                                  )
                                : SizedBox.shrink())
                      ]),
                      SizedBox(height: 24.0),
                      Row(children: [
                        Expanded(
                          child: Text(
                            _item.source.authors
                                .where((a) => a.name != null && a.type != null)
                                .map((a) => '· ' + a.name + ' - ' + a.type)
                                .join('\r\n'),
                            style: TextStyle(
                                color: Colour('#B1B8C1'),
                                letterSpacing: 0.3,
                                height: 1.6,
                                fontSize: 12.0),
                            overflow: TextOverflow.clip,
                          ),
                        )
                      ]),
                      SizedBox(height: 24.0),
                      Column(
                          children: _item.source.screens
                              .map(
                                (e) => Center(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        Definitions.contentBaseUrl + e.url,
                                    imageBuilder: (context, provider) {
                                      return Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 16),
                                          child: Image(image: provider));
                                    },
                                    //   errorWidget: (context, url, error) => Padding(
                                    //   padding: EdgeInsets.fromLTRB(0, 0, 0, 0)
                                    // ),
                                  ),
                                ),
                              )
                              .toList())
                    ]))));
  }

  var _currentFileIndex = 0;

  Widget _buildPlayerWidget(BuildContext context) {
    return Center(
        child: Container(
          height: 292.0,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      width: MediaQuery.of(context).size.width,
      color: Colour('#28384C'),
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
                    carouselController: _carouselController,
                    items: _files
                        .map((text) => Container(
                              padding: EdgeInsets.all(12.0),
                              child: Center(
                                      child: Text(
                                    text,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.0),
                                    maxLines: 3,
                                  )),
                                ))
                            .toList(),
                        options: CarouselOptions(
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
                  children: _files.map((f) {
                    int index = _files.indexOf(f);
                    return Container(
                      width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentFileIndex == index
                        ? Colour('#D8DCE0')
                        : Colour('546B7F'),
                  ),
                );
              }).toList(),
            ),
          ]),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text('00:00/12:00', style: TextStyle(fontSize: 12.0, color: Colour('#B1B8C1'))),
                Text(
                  '12:00', style: TextStyle(fontSize: 12.0, color: Colour('#B1B8C1'))
                ),
              ])),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SliderTheme(
              data: SliderThemeData(
                  activeTrackColor: Colour('#546B7F'),
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
          )
        ],
      ),
    ));
  }

  List<String> _getFiles(ItemDto item) {
    return item.source.tosec
        .where((s) =>
            s.path != null &&
            (extension(s.path).toLowerCase() == '.tzx' ||
                extension(s.path).toLowerCase() == '.tap'))
        .map((s) => basename(s.path))
        .toList();
  }

  Future _loadData() async {
    setState(() {
      _isLoading = true;
    });
    _item = await BackendService.getItem(_args.id);
    _files = _getFiles(_item);
    setState(() {
      _isLoading = false;
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