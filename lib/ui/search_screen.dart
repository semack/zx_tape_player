import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/services/backend_service.dart';
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
  bool isLoading = false;
  static int page = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textController.text = ModalRoute.of(context).settings.arguments;
    _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(16.0, 36.0, 16.0, 4.0),
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
                  await doSearch(_textController.text);
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
        onSuggestionSelected: (suggestion) async =>
            await doSearch(suggestion.text));
  }

  Widget _buildSearchList(BuildContext context) {
    return null;
  }

  Future doSearch(query) async {
    var items = await BackendService.getItems(query, Definitions.pageSize);
    var h = items.hits;
  }
}


