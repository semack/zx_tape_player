import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:zx_tape_player/exceptions/app_exception.dart';

class ApiBaseHelper {
  ApiBaseHelper(this._baseUrl, this._userAgent);

  final String _userAgent;
  final String _baseUrl;

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      var uri = _baseUrl + url;
      final response =
          await UserAgentClient(_userAgent, http.Client()).get(Uri.parse(uri));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
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
