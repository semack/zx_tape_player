
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:zx_tape_player/ui/player_screen.dart';
import 'package:zx_tape_player/ui/search_screen.dart';
import 'package:zx_tape_player/utils/app_center_initializer.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  static const routeName = '/home';

  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

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
    return Scaffold(
        body: Center(
            child: Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.fromLTRB(0, 100.0, 0, 0),
          child: Text(tr('find_tape'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.0, color: Theme.of(context).primaryColor))),
      Padding(
        padding: EdgeInsets.fromLTRB(16, 24.0, 16, 0),
        child: TextField(
          controller: _controller,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            letterSpacing: -0.5,
          ),
          autofocus: true,
          onChanged: (text) {
            if (text.isNotEmpty) {
              Navigator.pushNamed(context, SearchScreen.routeName,
                  arguments: text);
              _controller.text = '';
            }
          },
          cursorColor: Colors.white,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: tr('search_hint'),
            filled: true,
            fillColor: Colour('#28384C'),
            isDense: true,
            prefixIconConstraints: BoxConstraints(minWidth: 16, minHeight: 16),
            prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset('assets/images/home/search-icon.png')),
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
      ),
      Padding(
          padding: EdgeInsets.fromLTRB(0, 65.0, 0, 0),
          child: Text(tr('select_file'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.0, color: Theme.of(context).primaryColor))),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 24.0, 0, 0),
        child: FlatButton(
          color: Colour('#68B8DF'),
          textColor: Theme.of(context).primaryColor,
          padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
          onPressed: () async {
            FilePickerResult result = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: [
                'tap',
                'tzx',
              ],
            );

            if (result.files != null && result.files.length > 0)
              Navigator.pushNamed(context, PlayerScreen.routeName,
                  arguments: result.files.first);
          },
          child: Text(
            tr('select_from_files'),
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      )
    ])
        )
    );
  }
}
