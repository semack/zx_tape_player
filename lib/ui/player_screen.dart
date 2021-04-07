import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app_center_bundle_sdk/app_center_bundle_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/models/args/player_args.dart';
import 'package:zx_tape_player/models/software_model.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/services/responses/api_response.dart';
import 'package:zx_tape_player/ui/widgets/app_error.dart';
import 'package:zx_tape_player/ui/widgets/cassette.dart';
import 'package:zx_tape_player/ui/widgets/loading_progress.dart';
import 'package:zx_tape_player/ui/widgets/tape_player/tape_player.dart';
import 'package:zx_tape_player/utils/extensions.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key key}) : super(key: key);
  static const routeName = '/player';

  @override
  _PlayerScreenState createState() {
    return _PlayerScreenState();
  }
}

class Choice {
  const Choice({this.title, this.icon, this.pressed});

  final String title;
  final IconData icon;
  final Function pressed;
}

class _PlayerScreenState extends State<PlayerScreen> {
  _PlayerScreenBloc _bloc;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    var args = ModalRoute.of(this.context).settings.arguments;
    _bloc = _PlayerScreenBloc(args);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ApiResponse<SoftwareModel>>(
        stream: _bloc.softwareStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return Scaffold(
                    body: LoadingProgress(
                  loadingText: tr("loading"),
                ));
              case Status.COMPLETED:
                return _buildScreen(context, snapshot.data);
              case Status.ERROR:
                return Scaffold(
                    body: AppError(
                  text: tr('data_retrieving_error'),
                  buttonText: tr('retry'),
                  action: () => _bloc.refresh(),
                ));
            }
          }
          return SizedBox.shrink();
        });
  }

  Widget _buildScreen(
      BuildContext context, ApiResponse<SoftwareModel> response) {
    var model = response.data;

    List<Choice> choices = <Choice>[
      Choice(title: tr('open_tape_web'), icon: Icons.open_in_new_rounded),
      Choice(title: tr('share_tape'), icon: Icons.share_rounded)
    ];

    Future.sync(() => InAppReview.instance.isAvailable().then((value) {
          if (value)
            choices.add(Choice(
                title: tr('review_the_app'), icon: Icons.rate_review_rounded));
        }));

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actionsIconTheme:
            IconThemeData(size: 30.0, color: Colors.white, opacity: 10.0),
        actions: [
          (!model.isRemote)
              ? SizedBox.shrink()
              : PopupMenuButton<Choice>(
                  color: HexColor('#3B4E63'),
                  onSelected: (value) async {
                    if (value.title == tr('open_tape_web')) {
                      await _bloc.openExternalUrl(model.id);
                    } else if (value.title == tr('share_tape')) {
                      await _bloc.shareExternalUrl(model);
                    } else if (value.title == tr('review_the_app')) {
                      await InAppReview.instance.requestReview();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              choice.icon,
                              size: 16.0,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Text(choice.title,
                                style: TextStyle(
                                    letterSpacing: -0.5, color: Colors.white)),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
        ],
        title: Marquee(
          child: Text(model.title,
              style: TextStyle(color: Colors.white, letterSpacing: 0.1)),
        ),
        titleSpacing: 0.0,
        toolbarHeight: 60.0,
        backgroundColor: HexColor('#28384C'),
      ),
      body: Column(
        children: <Widget>[
          _buildInfoWidget(context, response),
          model.tapeFiles.length > 0
              ? TapePlayer(software: model)
              : Container(
                  color: HexColor('#3B4E63'),
                  height: 50.0,
                  child: Center(
                    child: Text(
                      tr('no_tapes'),
                      style: TextStyle(
                          fontSize: 14,
                          color: HexColor('#AFB6BB'),
                          letterSpacing: -0.5),
                    ),
                  ))
        ],
      ),
    );
  }
}

Widget _buildInfoWidget(
    BuildContext context, ApiResponse<SoftwareModel> response) {
  var model = response.data;
  return Expanded(
      child: Container(
          //color: Colors.black.withOpacity(0.7),
          color: HexColor('#172434'),
          child: !model.isRemote
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
                          var result = model.year ?? '';
                          if (model.genre != null) {
                            if (result.isNotEmpty) result += ' • ';
                            result += model.genre;
                          }
                          return Text(
                            result,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: HexColor('#B1B8C1'),
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
                              color: HexColor('#B1B8C1'),
                              size: 12.0,
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              model.votes?.toString() ?? tr('na'),
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                  fontSize: 12.0),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.star_rounded,
                              color: HexColor('#B1B8C1'),
                              size: 14.0,
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              model.score != null && model.score > 0
                                  ? model.score.toString()
                                  : tr('na'),
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                  fontSize: 12.0),
                            ),
                            SizedBox(width: 20),
                            Platform.isIOS
                                ? SizedBox.shrink()
                                : Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: HexColor('#B1B8C1'),
                                    size: 12.0,
                                  ),
                            SizedBox(width: 8),
                            Platform.isIOS
                                ? SizedBox.shrink()
                                : Text(
                                    model.price.isNullOrEmpty()
                                        ? tr('na')
                                        : model.price,
                                    style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                        fontSize: 12.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                        model.remarks.isNullOrEmpty()
                            ? SizedBox.shrink()
                            : SizedBox(height: 24.0),
                        model.remarks.isNullOrEmpty()
                            ? SizedBox.shrink()
                            : Row(children: [
                                Expanded(
                                    child: Text(
                                  model.remarks.removeAllHtmlTags(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                      height: 1.4,
                                      fontSize: 14.0),
                                  maxLines: 256,
                                ))
                              ]),
                        model.authors.length > 0
                            ? SizedBox(height: 24.0)
                            : SizedBox.shrink(),
                        model.authors.length > 0
                            ? Row(children: [
                                Expanded(
                                  child: Text(
                                    model.authors
                                        .map((a) =>
                                            '· ' + a.name + ' - ' + a.role)
                                        .join('\r\n'),
                                    style: TextStyle(
                                        color: HexColor('#B1B8C1'),
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
                            children: model.screenShotUrls
                                .map(
                                  (e) => Center(
                                      child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 24),
                                          child: Column(children: [
                                            CachedNetworkImage(
                                              imageUrl: e.url,
                                              imageBuilder:
                                                  (context, provider) {
                                                return Image(image: provider);
                                              },
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            Text(
                                              e.type,
                                              style: TextStyle(
                                                  color: HexColor('#B1B8C1'),
                                                  letterSpacing: 0.3,
                                                  fontSize: 12.0),
                                            )
                                          ]))),
                                )
                                .toList())
                      ]))));
}

class _PlayerScreenBloc {
  final PlayerArgs args;

  final _backendService = getIt<BackendService>();
  StreamController _softwareController =
      StreamController<ApiResponse<SoftwareModel>>();

  StreamSink<ApiResponse<SoftwareModel>> get softwareSink =>
      _softwareController.sink;

  Stream<ApiResponse<SoftwareModel>> get softwareStream =>
      _softwareController.stream;

  _PlayerScreenBloc(this.args) {
    _fetchData(args);
  }

  Future openExternalUrl(String id) async {
    var url = await _backendService.getExternalUrl(id);
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  Future shareExternalUrl(SoftwareModel model) async {
    var url = await _backendService.getExternalUrl(model.id);
    await Share.share(url, subject: model.title);
  }

  Future refresh() async {
    await _fetchData(args);
  }

  Future _fetchData(PlayerArgs args) async {
    softwareSink.add(ApiResponse.loading(''));
    try {
      SoftwareModel model;
      if (args.isRemote)
        model = await _backendService.fetchSoftware(args.id);
      else
        model = await _backendService.recognizeTape(args.id,
            localTitle: tr('local_file'));
      softwareSink.add(ApiResponse.completed(model));
    } catch (e) {
      softwareSink.add(ApiResponse.error(e.toString()));
      await AppCenter.trackEventAsync('error', e);
    }
  }

  dispose() {
    _softwareController?.close();
  }
}
