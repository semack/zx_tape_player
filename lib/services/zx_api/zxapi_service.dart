import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path/path.dart';
import 'package:zx_tape_player/models/hit_model.dart';
import 'package:zx_tape_player/models/software_model.dart';
import 'package:zx_tape_player/models/term_model.dart';
import 'package:zx_tape_player/services/backend_service.dart';
import 'package:zx_tape_player/utils/api_base_helper.dart';
import 'package:zx_tape_player/utils/definitions.dart';
import 'package:zx_tape_player/utils/extensions.dart';

import 'models/file_check_dto.dart';
import 'models/item_dto.dart';
import 'models/items_dto.dart';
import 'models/term_dto.dart';

class ZxApiService implements BackendService {
  static const _baseUrl = 'https://api.zxinfo.dk/v3';
  static const _contentBaseUrl = 'https://zxinfo.dk/media';
  static const _tapeBaseUrl =
      "https://archive.org/download/zx-spectrum-tosec-set-v-2020-02-18-lady-eklipse/%s.zip%s";
  static const _termsUrl = '/suggest/%s';
  static const _itemsUrl = '/search?query=%s&mode=tiny' +
      '&sort=rel_desc&contenttype=SOFTWARE&size=%s&offset=%s';
  static const _letterUrl = '/games/byletter/%s?mode=tiny' +
      '&contenttype=SOFTWARE&size=%s&offset=%s';
  static const _itemUrl = '/games/%s?mode=full';
  static const _fileCheckUrl = '/filecheck/%s';
  static const _externalUrl =
      'https://zxinfo.dk/details/%s?source=zxtapeplayer';
  static const _contentType = 'SOFTWARE';
  static const _userAgent = 'ZX Tape Player/1.0';

  final _helper = ApiBaseHelper(_baseUrl, _userAgent);

  Future<List<TermModel>> fetchTermsList(String query) async {
    var result = <TermModel>[];
    if (query.isEmpty) return result;
    if (query.length == 1) {
      var letter = await _tryGetLetter(query);
      if (letter != null && letter.isNotEmpty) {
        var item = TermModel(letter, Definitions.letterType);
        result.add(item);
        return result;
      }
    }
    var jsonResponse =
        await _helper.get(_termsUrl.format([query.safeEncode()]));
    result = (jsonResponse as List)
        .map((e) => TermDto.fromJson(e))
        .where((element) => element.type == _contentType)
        .map((e) => TermModel(e.text, e.type))
        .toList();
    return result;
  }

  Future<List<HitModel>> fetchHitsList(String query, int size,
      {int offset = 0}) async {
    var result = <HitModel>[];
    if (query.isEmpty) return result;
    var url = '';
    if (query.length == 1) {
      var letter = await _tryGetLetter(query);
      if (letter != null && letter.isNotEmpty) url += _letterUrl;
    }
    if (url.isEmpty) url += _itemsUrl;

    url = url.format([query.safeEncode(), size, offset]);
    url += Definitions.supportedTapeExtensions
        .map((e) => "&tosectype=%s".format([e]))
        .join();
    var jsonResponse = await _helper.get(url);
    var data = ItemsDto.fromJson(jsonResponse).hits.hits;
    if (data != null && data.length > 0)
      result = data
          .where((element) =>
              element.source != null &&
              element.source.title != null &&
              element.source.title.isNotEmpty)
          .map((e) => HitModel(
              e.id,
              e.source.screens.length > 0
                  ? _fixScreenShotUrl(e.source?.screens[0].url)
                  : '',
              e.source.title,
              e.source.originalYearOfRelease?.toString(),
              e.source.genreType,
              e.source.score?.votes,
              e.source.score.score))
          .toList();
    return result;
  }

  Future<SoftwareModel> fetchSoftware(String id,
      {String recognizedTapeFileName}) async {
    SoftwareModel result;
    var url = _baseUrl + _itemUrl.format([id]);
    var response =
        await UserAgentClient(_userAgent, http.Client()).get(Uri.parse(url));
    if (response.statusCode == 200) {
      var list = <ItemDto>[];
      list.add(ItemDto.fromJson(json.decode(response.body)));
      result = list
          .map((e) => SoftwareModel(
              e.id,
              true,
              e.source.title,
              e.source.originalYearOfRelease?.toString(),
              e.source.genre,
              e.source.score?.votes,
              e.source.score?.score,
              e.source.originalPrice != null
                  ? (e.source.originalPrice?.amount != null
                          ? ( e.source.originalPrice.prefix != null && e.source.originalPrice.prefix == 1 
                             ? e.source.originalPrice.currency + e.source.originalPrice.amount
                              : e.source.originalPrice.amount + e.source.originalPrice.currency )
                          : '')
                      .replaceAll('/', '')
                      .replaceAll('NA', '')
                  : '',
              e.source.remarks,
              e.source.authors
                  .where((a) =>
                      !(a.name.isNullOrEmpty() || a.type.isNullOrEmpty()))
                  .map((a) => AuthorModel(a.name, a.type))
                  .toList(),
              e.source.screens
                  .map((s) => ScreenShotModel(s.type, _fixScreenShotUrl(s.url)))
                  .toList(),
              recognizedTapeFileName,
              e.source.tosec
                  .where((t) => Definitions.supportedTapeExtensions
                      .contains(extension(t.path).replaceAll('.', '')))
                  .map((t) => _fixToSecUrl(t.path))
                  .toList()))
          .first;
    }
    return result;
  }

  Future<SoftwareModel> recognizeTape(String filePath,
      {String localTitle}) async {
    var md5 = await _calculateHash(filePath);
    var fileCheckUrl = _baseUrl + _fileCheckUrl.format([md5]);

    var result = await SoftwareModel.createFromFile(filePath, localTitle);

    if (!await InternetConnectionChecker().hasConnection) return result;

    var response = await UserAgentClient(_userAgent, http.Client())
        .get(Uri.parse(fileCheckUrl));
    if (response.statusCode == 200) {
      var fileCheck = FileCheckDto.fromJson(json.decode(response.body));
      result = await fetchSoftware(fileCheck.entryId,
          recognizedTapeFileName: fileCheck.file.filename);
    }

    return result;
  }

  Future<Uint8List> downloadTape(String url) async {
    var response =
        await UserAgentClient(_userAgent, http.Client()).get(Uri.parse(url));
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

  static String _fixScreenShotUrl(String url) {
    return _contentBaseUrl + url;
  }

  static String _fixToSecUrl(String url) {
    var prefix = url.split('/')[1];
    url = _tapeBaseUrl.format([prefix, url]);
    return url;
  }

  static Future<String> _calculateHash(String filePath) async {
    var result;
    var file = File(filePath);
    if (await file.exists()) {
      var bytes = await file.readAsBytes();
      var digest = sha512.convert(bytes);
      result = digest.toString();
    }
    return result;
  }

  Future<String> getExternalUrl(String id) async {
    return _externalUrl.format([id]);
  }
}

class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner;

  UserAgentClient(this.userAgent, this._inner);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}
