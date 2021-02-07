import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zx_tape_player/models/term_dto.dart';
import 'package:zx_tape_player/utils/extensions.dart';
import 'package:zx_tape_player/utils/user_agent_client.dart';

class BackendService {
  static const _baseUrl = 'https://api.zxinfo.dk/v3';
  static const _termsUrl = '/suggest/%s';
  static const _itemsUrl = '/search?query=%s%20runner&mode=compact' +
      '&sort=rel_desc&contenttype=SOFTWARE&size=1&offset=0';
  static const _itemUrl = '/games/%s?mode=compact';

  static const _contentType = 'SOFTWARE';
  static const  _userAgent = 'ZX Tape Player/1.0';

  static Future<List<TermDto>> getSuggestions(String query) async {
    var result = new List<TermDto>();

    if (query.isEmpty) return result;

    var url = (_baseUrl + _termsUrl).format([query]);
    var response = await new UserAgentClient(_userAgent, http.Client()).get(url);
    if (response.statusCode == 200) {
      result = (json.decode(response.body) as List)
          .map((e) => TermDto.fromMap(e))
          .where((element) => element.type == _contentType)
          .toList();
    }
    return result;
  }
}