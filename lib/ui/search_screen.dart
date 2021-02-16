import 'package:avatar_abc/AbcAvatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:zx_tape_player/models/items_dto.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);
  static const routeName = '/search';

  @override
  _SearchScreenState createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textController = TextEditingController();
  SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  static int _page = 0;
  var _initialized = false;
  List<Hits> _hits = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        await _getData(_textController.text, page: _page, adding: true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _textController.text = ModalRoute.of(context).settings.arguments;
      _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                  child: _buildSearchList(context),
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
            await _getData(text);
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
                  await _getData(_textController.text);
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
        loadingBuilder: (BuildContext context) {
          return Center(
            child: Text(
              tr('loading'),
              style: TextStyle(
                  fontSize: 14, color: Colour('#AFB6BB'), letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
          );
        },
        itemBuilder: (context, suggestion) {
          var text = suggestion.text;
          if (suggestion.type == Definitions.letterType)
            text = tr('all_tapes_by_letter').format([text]);
          return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.00),
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
          await _getData(suggestion.text);
        });
  }

  Widget _buildSearchList(BuildContext context) {
    return ListView.builder(
      itemCount: _hits.length + 1, // Add one more item for progress indicator
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (BuildContext context, int index) {
        if (index == _hits.length) {
          return _buildProgressIndicator();
        } else {
          var item = _hits[index];
          var url = item.source.screens.length > 0
              ? Definitions.contentBaseUrl + item.source.screens[0].url
              : '';
          var textAvatar = AbcAvatar(
            item.source.title,
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
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(4.0),
                          topRight: const Radius.circular(4.0))),
                  child: ListTile(
                    leading: new Container(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        width: 70.0,
                        height: 70.0,
                        child: CachedNetworkImage(
                            useOldImageOnUrlChange: true,
                            imageUrl: url,
                            placeholder: (context, url) => textAvatar,
                            errorWidget: (context, url, error) {
                              return textAvatar;
                            })),
                    title: Text(
                      item.source.title,
                      style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 0.3,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      item.source.genre,
                      style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 0.3,
                          fontSize: 10.0),
                    ),
                  )));
        }
      },
      controller: _scrollController,
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
            opacity: _isLoading ? 1.0 : 00,
            child: new DotsIndicator(
              dotsCount: 3,
              position: 0,
              decorator: DotsDecorator(
                color: Colour('#546B7F'), // Inactive color
                activeColor: Colour('#D8DCE0'),
              ),
            )),
      ),
    );
  }

  Future _getData(String query, {int page = 0, bool adding = false}) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      if (!adding) _hits.clear();

      var items = await BackendService.getItems(query, Definitions.pageSize,
          offset: page * Definitions.pageSize);

      _hits.addAll(items.hits.hits.where((element) =>
          element.source != null &&
          element.source.title != null &&
          element.source.title.isNotEmpty));

      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}


