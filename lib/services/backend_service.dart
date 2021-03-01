import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:zx_tape_player/models/application/hit_model.dart';
import 'package:zx_tape_player/models/application/item_model.dart';
import 'package:zx_tape_player/models/application/term_model.dart';
import 'package:zx_tape_player/models/remote/item_dto.dart';
import 'package:zx_tape_player/models/remote/items_dto.dart';
import 'package:zx_tape_player/models/remote/term_dto.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_player/utils/user_agent_client.dart';

class BackendService {
  static const _termsUrl = '/suggest/%s';
  static const _itemsUrl = '/search?query=%s&mode=compact' +
      '&sort=rel_desc&availability=Available&contenttype=SOFTWARE&size=%s&offset=%s';
  static const _letterUrl = '/games/byletter/%s?mode=compact' +
      '&availability=Available&contenttype=SOFTWARE&size=%s&offset=%s';
  static const _itemUrl = '/games/%s?mode=full';

  static Future<List<TermModel>> getSuggestions(String query) async {
    var result = new List<TermModel>();
    if (query.isEmpty) return result;
    if (query.length == 1) {
      var letter = await _tryGetLetter(query);
      if (letter != null && letter.isNotEmpty) {
        var item = TermModel(letter, Definitions.letterType);
        result.add(item);
        return result;
      }
    }
    var url = (Definitions.baseUrl + _termsUrl).format([query]);
    var response =
        await UserAgentClient(Definitions.userAgent, http.Client()).get(url);
    if (response.statusCode == 200) {
      result = (json.decode(response.body) as List)
          .map((e) => TermDto.fromJson(e))
          .where((element) => element.type == Definitions.contentType)
          .map((e) => TermModel(e.text, e.type))
          .toList();
    }
    return result;
  }

  static Future<List<HitModel>> getHits(String query, int size,
      {int offset = 0}) async {
    var result = <HitModel>[];
    if (query.isEmpty) return result;
    var url = Definitions.baseUrl;
    if (query.length == 1) {
      var letter = await _tryGetLetter(query);
      if (letter != null && letter.isNotEmpty) url += _letterUrl;
    }
    if (url == Definitions.baseUrl) url += _itemsUrl;
    url = url.format([query, size, offset]);
    var response =
        await UserAgentClient(Definitions.userAgent, http.Client()).get(url);
    if (response.statusCode == 200) {
      var data = ItemsDto.fromJson(json.decode(response.body)).hits.hits;
      if (data != null && data.length > 0)
        result = data
            .where((element) =>
                element.source != null &&
                element.source.title != null &&
                element.source.title.isNotEmpty)
            .map((e) => HitModel(
                e.id,
                e.source.screens.length > 0
                    ? fixScreenShotUrl(e.source?.screens[0].url)
                    : '',
                e.source.title,
                e.source.originalYearOfRelease?.toString(),
                e.source.genreType,
                e.source.score?.votes,
                e.source.score.score))
            .toList();
    }
    return result;
  }

  static Future<ItemModel> getItem(String id) async {
    ItemModel result;
    var url = Definitions.baseUrl + _itemUrl.format([id]);
    var response =
        await UserAgentClient(Definitions.userAgent, http.Client()).get(url);
    if (response.statusCode == 200) {
      var list = <ItemDto>[];
      list.add(ItemDto.fromJson(json.decode(response.body)));
      result = list
          .map((e) => ItemModel(
              e.source.title,
              e.source.originalYearOfRelease?.toString(),
              e.source.genre,
              e.source.score?.votes,
              e.source.score?.score,
              (e.source.originalPrice?.amount ??
                  '' +
                      (e.source.originalPrice?.currency ?? '')
                          .replaceAll('/', '')
                          .replaceAll('NA', '')),
              e.source.remarks,
              e.source.authors?.map((a) => AuthorModel(a.name, a.type)),
              e.source.screens
                  .map((s) => ScreenShotModel(s.type, fixScreenShotUrl(s.url))),
              e.source.tosec
                  .where((t) => Definitions.supportedTapeExtensions
                      .contains(extension(t.path)))
                  .map((t) => fixToSecUrl(t.path))))
          .first;
    }
    return result;
  }

  static Future<Uint8List> downloadTape(String url) async {
    var response =
        await UserAgentClient(Definitions.userAgent, http.Client()).get(url);
    if (response.statusCode == 200) return response.bodyBytes;
    return null;
  }

  static Future<String> _tryGetLetter(String query) async {
    if (query.isNotEmpty) {
      var letter = query.toUpperCase()[0];
      if (new RegExp(r'^[0-9a-zA-Z]+').hasMatch(letter)) return letter;
    }
    return null;
  }

  static String fixScreenShotUrl(String url) {
    if (url.startsWith('/zxscreens')) return Definitions.contentBaseUrl2 + url;
    return Definitions.contentBaseUrl + url;
  }

  static String fixToSecUrl(String url) {
    var prefix = url.split('/')[1];
    url = Definitions.tapeBaseUrl.format([prefix, url]);
    return url;
  }
}
