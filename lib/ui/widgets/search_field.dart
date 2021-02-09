import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:zx_tape_player/services/backend.dart';
import 'package:zx_tape_player/ui/screens/player.dart';

class SearchField extends StatelessWidget {
  SearchField({Key key}) : super(key: key);
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _textController.text = ModalRoute
        .of(context)
        .settings
        .arguments;
    _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length));
    return
      Padding(
        padding: EdgeInsets.fromLTRB(16.0, 36.0, 16.0, 4.0),
        child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _textController,
            style: TextStyle(
                color: Colors.white, fontSize: 18.0, letterSpacing: -0.5),
            autofocus: true,
            cursorColor: Colors.white,
            onChanged: (text) {
              if (text.isEmpty) Navigator.pop(context);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colour("#546B7F")),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              hintText: tr('search_hint'),
              filled: true,
              fillColor: Colour('#28384C'),
              isDense: true,
              prefixIconConstraints:
              BoxConstraints(minWidth: 16, minHeight: 16),
              prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Image.asset('assets/images/home/search-icon.png')),
              hintStyle: TextStyle(
                fontSize: 16.0,
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
                    fontSize: 14,
                    color: Colour('#AFB6BB'),
                    letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
            );
          },
          loadingBuilder: (BuildContext context) {
            return Center(
              child: Text(
                tr('loading'),
                style: TextStyle(
                    fontSize: 14,
                    color: Colour('#AFB6BB'),
                    letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
            );
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0.00),
                // key: Key(item.entryId),
                trailing: Text('>', style: TextStyle(color: Colour('#AFB6BB'))),
                title: Text(suggestion.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      height: 1.8,
                      letterSpacing: -0.5,
                    )));
          },
          onSuggestionSelected: (suggestion) =>
              Navigator.pushNamed(
                  context, PlayerScreen.routeName,
                  arguments: suggestion.entryId),
        ),
      );
  }
}