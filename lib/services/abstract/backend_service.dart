import 'dart:typed_data';

import 'package:zx_tape_player/models/application/hit_model.dart';
import 'package:zx_tape_player/models/application/software_model.dart';
import 'package:zx_tape_player/models/application/term_model.dart';

abstract class BackendService {
  Future<List<TermModel>> fetchTermsList(String query);

  Future<List<HitModel>> fetchHitsList(String query, int size, {int offset = 0});

  Future<SoftwareModel> fetchSoftware(String id);

  Future<SoftwareModel> recognizeTape(String filePath, {String localTitle});

  Future<Uint8List> downloadTape(String url);

  Future<String> getExternalUrl(String id);
}
