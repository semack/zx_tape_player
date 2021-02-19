import 'package:carousel_slider/carousel_slider.dart';
import 'package:colour/colour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:zx_tape_player/models/item_dto.dart';
import 'package:zx_tape_player/models/player_args.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/ui/widgets/loading_progress.dart';
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
  ItemDto _item;
  PlayerArgs _args;
  bool _isLoading = true;

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
    _args = ModalRoute.of(this.context).settings.arguments;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    //_loadData();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _args.title,
          overflow: TextOverflow.fade,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: 60.0,
        backgroundColor: Colour('#28384C'),
      ),
      body: _isLoading
          ? LoadingProgress()
          : Column(
              children: <Widget>[
                _buildInfoWidget(context),
                _buildPlayerWidget(context)
              ],
            ),
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
            color: Colour('#172434'),
            child: SingleChildScrollView(
                child: Column(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _item.source.originalYearOfRelease != null
                        ? _item.source.originalYearOfRelease.toString()
                        : '',
                    style: TextStyle(
                        color: Colour('#B1B8C1'),
                        letterSpacing: 0.3,
                        fontSize: 12.0),
                  ),
                  Text(
                    _item.source.originalYearOfRelease != null &&
                            _item.source.genre != null
                        ? ' • '
                        : '',
                    style: TextStyle(
                        color: Colour('#B1B8C1'),
                        letterSpacing: 0.3,
                        fontSize: 12.0),
                  ),
                  Text(
                    _item.source.genre != null ? _item.source.genre : '',
                    style: TextStyle(
                        color: Colour('#B1B8C1'),
                        letterSpacing: 0.3,
                        fontSize: 12.0),
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
              SizedBox(height: 14.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/search/like.png',
                      width: 12.0, height: 12.0),
                  SizedBox(width: 5),
                  Text(
                    _item.source.score.votes != null
                        ? _item.source.score.votes.toString()
                        : tr('na'),
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.3,
                        fontSize: 12.0),
                  ),
                  SizedBox(width: 20),
                  Image.asset('assets/images/search/star.png',
                      width: 12.0, height: 12.0),
                  SizedBox(width: 5),
                  Text(
                    _item.source.score.score != null &&
                            _item.source.score.score > 0
                        ? _item.source.score.score.toString()
                        : tr('na'),
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.3,
                        fontSize: 12.0),
                  ),
                  SizedBox(width: 20),
                  Text(
                    _item.source.originalPrice != null &&
                            _item.source.originalPrice.amount.isNotEmpty
                        ? _item.source.originalPrice.amount
                        : '',
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.3,
                        fontSize: 12.0),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    _item.source.originalPrice != null &&
                            _item.source.originalPrice.currency
                                    .replaceAll('/', '') !=
                                'NA'
                        ? _item.source.originalPrice.currency
                        : '',
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.3,
                        fontSize: 12.0),
                  ),
                ],
              ),
              _item.source.remarks != null
                  ? SizedBox(height: 24.0)
                  : SizedBox.shrink(),
              Row(children: [
                Expanded(
                    child: _item.source.remarks != null
                        ? Text(
                            _item.source.remarks.removeAllHtmlTags(),
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.3,
                                height: 1.4,
                                fontSize: 14.0),
                            maxLines: 256,
                          )
                        : SizedBox.shrink())
              ]),
              SizedBox(height: 24.0),
              Row(children: [
                Expanded(
                  child: Text(
                    _item.source.authors
                        .where((a) => a.name != null && a.type != null)
                        .map((a) => '· ' + a.name + ' - ' + a.type)
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
            ]))));
  }

  var _currentFileIndex = 0;

  Widget _buildPlayerWidget(BuildContext context) {
    return Center(
        child: Container(
      height: 292.0,
      color: Colour('#28384C'),
      child: Column(
        children: [
          Row(
            children: [
              Column(children: [
                Container(
                    //color: Colors.blue,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    width: MediaQuery.of(context).size.width,
                    height: 112,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colour('#172434'),
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                      child: CarouselSlider(
                        items: _getPaths(_item)
                            .map((text) => Container(
                                  padding: EdgeInsets.all(12.0),
                                  child: Center(
                                      child: Text(
                                    text,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.0),
                                    maxLines: 3,
                                  )),
                                ))
                            .toList(),
                        options: CarouselOptions(
                            autoPlay: false,
                            enlargeCenterPage: false,
                            aspectRatio: 2.0,
                            viewportFraction: 1.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentFileIndex = index;
                              });
                            }),
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getPaths(_item).map((f) {
                    int index = _getPaths(_item).indexOf(f);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentFileIndex == index
                            ? Colour('#D8DCE0')
                            : Colour('546B7F'),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ],
          ),
          Row(),
          Row(),
          Row(),
        ],
      ),
    ));
  }

  List<String> _getPaths(ItemDto item) {
    return item.source.tosec
        .where((s) =>
            s.path != null &&
            (extension(s.path) == '.tzx' || extension(s.path) == '.tap'))
        .map((f) => basename(f.path))
        .toList();
  }

  Future _loadData() async {
    setState(() {
      _isLoading = true;
    });
    _item = await BackendService.getItem(_args.id);
    setState(() {
      _isLoading = false;
    });
  }
}
