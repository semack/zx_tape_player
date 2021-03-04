import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/models/application/software_model.dart';
import 'package:zx_tape_player/models/args/player_args.dart';
import 'package:zx_tape_player/models/enums/file_location.dart';
import 'package:zx_tape_player/services/abstract/backend_service.dart';
import 'package:zx_tape_player/ui/widgets/cassette.dart';
import 'package:zx_tape_player/ui/widgets/loading_progress.dart';
import 'package:zx_tape_player/ui/widgets/tape_player.dart';
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
  SoftwareModel _item;
  bool _isLoading = true;
  String _title;

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
    var args = ModalRoute.of(this.context).settings.arguments;
    _loadData(args);
  }

  Future _loadData(PlayerArgs args) async {
    switch (args.location) {
      case FileLocation.remote:
        _item = await getIt<BackendService>().getItem(args.id);
        _title = _item.title;
        break;
      case FileLocation.file:
        _item = await getIt<BackendService>().recognizeTape(args.id);
        _title = _item.title ?? tr('local_file');
        break;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading
          ? null
          : AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                _item.isRemote
                    ? IconButton(
                        icon: Icon(
                          Icons.open_in_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () async {
                          var url = await getIt<BackendService>()
                              .getExternalUrl(_item.id);
                          await canLaunch(url)
                              ? await launch(url)
                              : throw 'Could not launch $url';
                        })
                    : SizedBox.shrink()
              ],
              title: Marquee(
                child: Text(_title,
                    style: TextStyle(color: Colors.white, letterSpacing: 0.1)),
              ),
              titleSpacing: 0.0,
              toolbarHeight: 60.0,
              backgroundColor: Colour('#28384C'),
            ),
      body: _isLoading
          ? LoadingProgress(
              loadingText: tr("loading"),
            )
          : Column(
              children: <Widget>[
                _buildInfoWidget(context),
                _item.tapeFiles.length > 0
                    ? TapePlayer(
                        files: _item.tapeFiles.toList(),
                        audioPlayer: audioPlayer,
                      )
                    : _buildNoFilesWidget(context)
              ],
            ),
    );
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
            child: !_item.isRemote
                ? Center(
                    child: Container(
                    child: Cassette(
                      animated: false,
                    ),
                  ))
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                    //clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(builder: (context, snapshot) {
                            var result = _item.year ?? '';
                            if (_item.genre != null) {
                              if (result.isNotEmpty) result += ' • ';
                              result += _item.genre;
                            }
                            return Text(
                              result,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colour('#B1B8C1'),
                                  letterSpacing: 0.3,
                                  fontSize: 12.0),
                            );
                          }),
                          SizedBox(height: 14.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thumb_up_rounded,
                                color: Colour('#B1B8C1'),
                                size: 12.0,
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                _item.votes?.toString() ?? tr('na'),
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                    fontSize: 12.0),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.star_rounded,
                                color: Colour('#B1B8C1'),
                                size: 14.0,
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                _item.score != null && _item.score > 0
                                    ? _item.score.toString()
                                    : tr('na'),
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                    fontSize: 12.0),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.attach_money_rounded,
                                color: Colour('#B1B8C1'),
                                size: 14.0,
                              ),
                              SizedBox(width: 2),
                              Text(
                                _item.price.isNullOrEmpty()
                                    ? tr('na')
                                    : _item.price,
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                    fontSize: 12.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          _item.remarks.isNullOrEmpty()
                              ? SizedBox.shrink()
                              : SizedBox(height: 24.0),
                          _item.remarks.isNullOrEmpty()
                              ? SizedBox.shrink()
                              : Row(children: [
                                  Expanded(
                                      child: Text(
                                    _item.remarks.removeAllHtmlTags(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                        height: 1.4,
                                        fontSize: 14.0),
                                    maxLines: 256,
                                  ))
                                ]),
                          _item.authors.length > 0
                              ? SizedBox(height: 24.0)
                              : SizedBox.shrink(),
                          _item.authors.length > 0
                              ? Row(children: [
                                  Expanded(
                                    child: Text(
                                      _item.authors
                                          .map((a) =>
                                              '· ' + a.name + ' - ' + a.role)
                                          .join('\r\n'),
                                      style: TextStyle(
                                          color: Colour('#B1B8C1'),
                                          letterSpacing: 0.3,
                                          height: 1.6,
                                          fontSize: 12.0),
                                      overflow: TextOverflow.clip,
                                    ),
                                  )
                                ])
                              : SizedBox.shrink(),
                          SizedBox(height: 24.0),
                          Column(
                              children: _item.screenShotUrls
                                  .map(
                                    (e) => Center(
                                        child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 0, 16),
                                            child: Column(children: [
                                              CachedNetworkImage(
                                                imageUrl: e.url,
                                                imageBuilder:
                                                    (context, provider) {
                                                  return Image(image: provider);
                                                },
                                              ),
                                              SizedBox(
                                                height: 4.0,
                                              ),
                                              Text(
                                                e.type,
                                                style: TextStyle(
                                                    color: Colour('#B1B8C1'),
                                                    letterSpacing: 0.3,
                                                    fontSize: 12.0),
                                              )
                                            ]))),
                                  )
                                  .toList())
                        ]))));
  }
}
