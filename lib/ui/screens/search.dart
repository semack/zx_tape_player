import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/ui/screens/player.dart';
import 'package:zx_tape_player/ui/widgets/search_field.dart';


class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);
  static const routeName = '/search';

  @override
  _SearchScreenState createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final _scrollController = ScrollController();
  bool isLoading = false;
  static int page = 0;

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
        body: Column(
          children: <Widget>[
            SearchField(),
            Expanded(
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: _buildSearchList(context),

                ))
          ],
        ), resizeToAvoidBottomPadding: false);
  }

  Widget _buildSearchList(BuildContext context) {

  }
}


