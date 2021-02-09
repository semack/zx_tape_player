import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:zx_tape_player/models/term_dto.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_player/utils/user_agent_client.dart';

class BackendService {
  static const _baseUrl = 'https://api.zxinfo.dk/v3';
  static const _termsUrl = '/suggest/%s';
  static const _itemsUrl = '/search?query=%s%20runner&mode=compact' +
      '&sort=rel_desc&contenttype=SOFTWARE&size=%s&offset=%s';
  static const _letterUrl = '/games/byletter/%s?mode=compact&size=%s&offset=%s';

  static const _contentType = 'SOFTWARE';
  static const  _userAgent = 'ZX Tape Player/1.0';

  static Future<List<TermDto>> getSuggestions(String query) async {
    var result = new List<TermDto>();
    if (query.isEmpty) return result;
    if (query.length == 1) {
      var letter = query.toUpperCase()[0];
      if (new RegExp(r'^[0-9a-zA-Z]+').hasMatch(letter)) {
        var item = new TermDto();
        item.entryId = letter;
        item.type = 'LETTER';
        item.text = tr('all_tapes_by_letter').format([letter]);
        result.insert(0, item);
      }
    } else {
      var url = (_baseUrl + _termsUrl).format([query]);
      var response =
          await new UserAgentClient(_userAgent, http.Client()).get(url);
      if (response.statusCode == 200) {
        result = (json.decode(response.body) as List)
            .map((e) => TermDto.fromMap(e))
            .where((element) => element.type == _contentType)
            .toList();
      }
    }
    return result;
  }
}