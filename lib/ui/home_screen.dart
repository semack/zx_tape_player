import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:zx_tape_player/models/args/player_args.dart';
import 'package:zx_tape_player/models/enums/file_location.dart';
import 'package:zx_tape_player/ui/player_screen.dart';
import 'package:zx_tape_player/ui/search_screen.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                padding: EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 0),
                child: Column(children: <Widget>[
                  Text(tr('find_tape'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).primaryColor)),
                  SizedBox(
                    height: 24.0,
                  ),
                  TextField(
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
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 16, minHeight: 16),
                      prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Image.asset(
                              'assets/images/home/search-icon.png')),
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colour('546B7F'),
                        letterSpacing: -0.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
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
                  SizedBox(
                    height: 65.0,
                  ),
                  Text(tr('select_file'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).primaryColor)),
                  SizedBox(height: 24.0),
                  FlatButton(
                    color: Colour('#68B8DF'),
                    textColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                    onPressed: () async {
                      FilePicker.platform.clearTemporaryFiles();
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        allowCompression: false,
                        allowMultiple: false,
                        //allowedExtensions: Definitions.supportedTapeExtensions
                      );
                      if (result != null) {
                        PlatformFile file = result.files.first;
                        if (Definitions.supportedTapeExtensions.any((element) =>
                            element.toLowerCase() ==
                            file.extension.toLowerCase())) {
                          Navigator.pushNamed(context, PlayerScreen.routeName,
                              arguments:
                                  PlayerArgs(file.path, FileLocation.file));
                        } else {
                          final snackBar = SnackBar(
                            backgroundColor: Colour('#D9512D'),
                            content: Text(
                              tr('invalid_file_format').format([
                                Definitions.supportedTapeExtensions
                                    .map((e) => '.'+e.toUpperCase()).join(', ')
                              ]),
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          );
                          Future.delayed(const Duration(), () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          });
                        }
                      }
                    },
                    child: Text(
                      tr('select_from_files'),
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ]))));
  }
}
