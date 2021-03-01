import 'package:avatar_abc/AbcAvatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zx_tape_player/models/application/hit_model.dart';
import 'package:zx_tape_player/models/remote/items_dto.dart';
import 'package:zx_tape_player/models/args/player_args.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/ui/player_screen.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_player/main.dart';
import 'package:zx_tape_player/ui/widgets/loading_progress.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);
  static const routeName = '/search';

  @override
  _SearchScreenState createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> with RouteAware {
  TextEditingController _textController = TextEditingController();
  SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  static int _page = 0;
  var _initialized = false;
  var _isNewSearch = false;
  var _hits = <HitModel>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(this.context));
    if (!_initialized) {
      _textController.text = ModalRoute.of(context).settings.arguments;
      _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
      _initialized = true;
    }
  }

  @override
  void didPopNext() {
    audioPlayer.setFilePath('');
    audioPlayer.stop();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _refreshController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 4.0),
                child: _buildSearchField(context)),
            Expanded(
                child: Container(
              width: MediaQuery.of(context).size.width,
              child:
                  _isNewSearch ? LoadingProgress() : _buildSearchList(context),
            ))
          ],
        ),
        resizeToAvoidBottomPadding: false);
  }

  Widget _buildSearchField(BuildContext context) {
    return TypeAheadField(
        suggestionsBoxController: _suggestionsBoxController,
        textFieldConfiguration: TextFieldConfiguration(
          controller: _textController,
          onSubmitted: (text) async {
            _textController.text = text;
            await _onLoading();
          },
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, letterSpacing: -0.5),
          autofocus: true,
          cursorColor: Colors.white,
          onChanged: (text) async {
            if (text.isEmpty) Navigator.pop(context);
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: _textController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close, color: Colour("#546B7F")),
                    onPressed: () {
                      setState(() {
                        _textController.clear();
                      });
                      Navigator.pop(context);
                    }),
            suffixIcon: IconButton(
                icon: Icon(Icons.search, color: Colour("#68AD56")),
                onPressed: () async {
                  _suggestionsBoxController.close();
                  await _onLoading();
                }),
            hintText: tr('search_hint'),
            filled: true,
            fillColor: Colour('#28384C'),
            isDense: true,
            hintStyle: TextStyle(
              fontSize: 14.0,
              color: Colour('546B7F'),
              letterSpacing: -0.5,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.0),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0.0),
              borderRadius: BorderRadius.circular(3.5),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0.0),
              borderRadius: BorderRadius.circular(3.5),
            ),
          ),
        ),
        suggestionsCallback: (pattern) async {
          return await BackendService.getSuggestions(pattern);
        },
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          hasScrollbar: false,
          elevation: 0,
          constraints: BoxConstraints(minWidth: 0, minHeight: 0),
          shadowColor: Colors.transparent,
          color: Colour('#546B7F'),
        ),
        noItemsFoundBuilder: (BuildContext context) {
          return Center(
            child: Text(
              tr('no_items_found'),
              style: TextStyle(
                  fontSize: 14, color: Colour('#AFB6BB'), letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
          );
        },
        loadingBuilder: (BuildContext context) => LoadingProgress(),
        itemBuilder: (context, suggestion) {
          var text = suggestion.text;
          if (suggestion.type == Definitions.letterType)
            text = tr('all_tapes_by_letter').format([text]);
          return ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 0.00, vertical: 0.00),
              trailing: Text('>', style: TextStyle(color: Colour('#AFB6BB'))),
              title: Text(text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    height: 1.8,
                    letterSpacing: -0.5,
                  )));
        },
        onSuggestionSelected: (suggestion) async {
          _textController.text = suggestion.text;
          await _onLoading();
        });
  }

  Widget _buildSearchList(BuildContext context) {
    return SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        controller: _refreshController,
        onLoading: () async => _onLoading(adding: true),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            var hint = '';
            switch (mode) {
              // case LoadStatus.idle:
              //   hint = tr('pull_up_to_load');
              //   break;
              case LoadStatus.loading:
                return Container(
                    height: 55.0,
                    child: Center(
                      child: Loading(
                          indicator: BallPulseIndicator(),
                          size: 30.0,
                          color: Colour('#AFB6BB')),
                    ));
              case LoadStatus.failed:
                return Container(
                  height: 55.0,
                  child: Center(
                      child: Text(tr('load_failed_retry'),
                          style: TextStyle(
                              fontSize: 11, color: Colour('#B1B8C1')))),
                );
              //break;
              // case LoadStatus.canLoading:
              //   hint = tr('release_load_more');
              //   break;
              // case LoadStatus.noMore:
              //   hint = tr('no_more_data');
              //   break;
            }
            return SizedBox(
              height: 0.0,
            );
          },
        ),
        child: ListView.builder(
            // itemExtent: 102.0,
            //padding: EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (BuildContext context, int index) {
          if (index >= _hits.length) return null;
          var item = _hits[index];
          var textAvatar = AbcAvatar(
            item.title,
            isRectangle: true,
            // circleConfiguration: CircleConfiguration(radius: 50),
            rectangeConfiguration: RectangeConfiguration(
                borderRadius: 4,
                blurRadius: 0,
                shadowColor: Colors.transparent),
            titleConfiguration:
                TitleConfiguration(fontWeight: FontWeight.bold, size: 30),
          );
          return Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 6.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colour('#3B4E63'),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  child: ListTile(
                      onTap: () async => Navigator.pushNamed(
                          context, PlayerScreen.routeName,
                          arguments: PlayerArgs(
                              PlayerArgsTypeEnum.network, item.id, item.title)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                      leading: new Container(
                          width: 60.0,
                          height: 75.0,
                          padding: EdgeInsets.zero,
                          child: CachedNetworkImage(
                              imageRenderMethodForWeb:
                                  ImageRenderMethodForWeb.HttpGet,
                              useOldImageOnUrlChange: true,
                              imageUrl: item.iconUrl,
                              imageBuilder: (context, provider) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                      image: DecorationImage(
                                        image: provider,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) => textAvatar,
                              errorWidget: (context, url, error) {
                                return textAvatar;
                              })),
                      title: Text(
                        item.title,
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0.3,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                      ),
                      isThreeLine: true,
                      subtitle: Column(children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FutureBuilder(builder: (context, snapshot) {
                              var result = item.year ?? '';
                              if (item.genre != null) {
                                if (result.isNotEmpty) result += ' • ';
                                result += item.genre;
                              }
                              return Text(
                                result,
                                style: TextStyle(
                                    color: Colour('#B1B8C1'),
                                    letterSpacing: 0.3,
                                    fontSize: 12.0),
                              );
                            }),
                          ],
                        ),
                        SizedBox(height: 5.0),
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
                              item.votes?.toString() ?? tr('na'),
                              style: TextStyle(
                                  color: Colour('#B1B8C1'),
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
                              item.score != null && item.score > 0
                                  ? item.score.toString()
                                  : tr('na'),
                              style: TextStyle(
                                  color: Colour('#B1B8C1'),
                                  letterSpacing: 0.3,
                                  fontSize: 12.0),
                            ),
                          ],
                        )
                      ]))));
        }));
  }

  Future _onLoading({bool adding = false}) async {
    if (!adding) {
      setState(() {
        _hits.clear();
        _page = 0;
        _isNewSearch = true;
      });
    }
    try {
      var items = await BackendService.getHits(
          _textController.text, Definitions.pageSize,
          offset: _page * Definitions.pageSize);
      _hits.addAll(items);
      if (items.length > 0) {
        _page++;
        _refreshController.loadComplete();
      } else
        _refreshController.loadNoData();
    } catch (e) {
      _refreshController.loadFailed();
      await AppCenter.trackEventAsync('error', e);
    }
    setState(() {
      _isNewSearch = false;
    });
  }
}
