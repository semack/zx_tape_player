import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zx_tape_player/models/item_dto.dart';
import 'package:zx_tape_player/models/items_dto.dart';
import 'package:zx_tape_player/models/term_dto.dart';
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

  static Future<List<TermDto>> getSuggestions(String query) async {
    var result = new List<TermDto>();
    if (query.isEmpty) return result;
    if (query.length == 1) {
      var letter = await _tryGetLetter(query);
      if (letter != null && letter.isNotEmpty) {
        var item = TermDto(
            text: letter, entryId: letter, type: Definitions.letterType);
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
          .toList();
    }
    return result;
  }

  static Future<ItemsDto> getItems(String query, int size,
      {int offset = 0}) async {
    var result = ItemsDto();
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
    if (response.statusCode == 200)
      result = ItemsDto.fromJson(json.decode(response.body));
    return result;
  }

  static Future<ItemDto> getItem(String id) async {
    ItemDto result;
    var url = Definitions.baseUrl + _itemUrl.format([id]);
    var response =
        await UserAgentClient(Definitions.userAgent, http.Client()).get(url);
    // try {
      if (response.statusCode == 200)
        result = ItemDto.fromJson(json.decode(response.body));
    // }
    // catch(e)
    // {
    //     var z = e;
    // }
    return result;
  }

  static Future<String> _tryGetLetter(String query) async {
    if (query.isNotEmpty) {
      var letter = query.toUpperCase()[0];
      if (new RegExp(r'^[0-9a-zA-Z]+').hasMatch(letter)) return letter;
    }
    return null;
  }
}