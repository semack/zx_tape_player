import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:zx_tape_player/services/backend.dart';
import 'package:zx_tape_player/ui/screens/player.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/search';

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    _controller.text = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        body: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, 36.0, 16.0, 4.0),
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              onChanged: (text) {
                if (text.length == 0) Navigator.of(context).pop();
              },
              autofocus: true,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Type a search text here',
                filled: true,
                fillColor: Colour('#28384C'),
                prefixIcon: Image.asset('assets/images/home/search-icon.png'),
                hintStyle: TextStyle(fontSize: 16.0, color: Colour('546B7F')),
                contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
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
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text(suggestion['name']),
                subtitle: Text('\$${suggestion['price']}'),
              );
            },
            onSuggestionSelected: (suggestion) => Navigator.pushNamed(
                context, PlayerScreen.routeName,
                arguments: suggestion['name']),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, 36.0, 16.0, 4.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white),
                  autofocus: true,
                  // onChanged: (text) {
                  //   Navigator.pushNamed(context, SearchScreen.routeName,
                  //       arguments: text);
                  // },
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type a search text here',
                    filled: true,
                    fillColor: Colour('#28384C'),
                    prefixIcon:
                        Image.asset('assets/images/home/search-icon.png'),
                    hintStyle:
                        TextStyle(fontSize: 16.0, color: Colour('546B7F')),
                    contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0.0),
                      borderRadius: BorderRadius.circular(3.5),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0.0),
                      borderRadius: BorderRadius.circular(3.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: Container(
          width: MediaQuery.of(context).size.width,
        ))
      ],
    ));
  }
}
