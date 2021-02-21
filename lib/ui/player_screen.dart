import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/models/item_dto.dart';
import 'package:zx_tape_player/models/player_args.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/ui/widgets/cassette.dart';
import 'package:zx_tape_player/ui/widgets/loading_progress.dart';
import 'package:zx_tape_player/ui/widgets/player.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_player/utils/platform.dart';

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
  List<String> _files = [];
  PlayerArgs _args;
  bool _isLoading = true;

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
    if (_args.type == PlayerArgsTypeEnum.file) {
      setState(() {
        _isLoading = false;
        _files.add(_args.id);
      });
    } else
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
                    ? Player(
                        files: _files,
                        sourceType: _args.type,
                        audioPlayer: audioPlayer,
                      )
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
        child: Container(
          //color: Colors.black.withOpacity(0.7),
            color: Colour('#172434'),
            child: _args.type == PlayerArgsTypeEnum.file
                ? Center(
                    child: Container(
                    child: Cassette(
                      animated: false,
                    ),
                  ))
                : SingleChildScrollView(
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
                              Icon(
                                Icons.thumb_up_rounded,
                                color: Colour('#B1B8C1'),
                                size: 12.0,
                              ),
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
                              Icon(
                                Icons.star_rounded,
                                color: Colour('#B1B8C1'),
                                size: 14.0,
                              ),
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
                                        _item.source.originalPrice.amount !=
                                            null
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
                                _item.source.originalPrice != null &&
                                        _item.source.originalPrice.currency !=
                                            null &&
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
                                        _item.source.remarks
                                            .removeAllHtmlTags(),
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
                                    .where(
                                        (a) => a.name != null && a.type != null)
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
                                        imageUrl: fixScreenShotUrl(e.url),
                                        imageBuilder: (context, provider) {
                                          return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 16),
                                              child: Image(image: provider));
                                        },
                                      ),
                                    ),
                                  )
                                  .toList())
                        ]))));
  }

  List<String> _getFiles(ItemDto item) {
    return item.source.tosec
        .where((s) =>
            s.path != null &&
            (extension(s.path).toLowerCase() == '.tzx' ||
                extension(s.path).toLowerCase() == '.tap'))
        .map((s) => s.path)
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
