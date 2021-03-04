import 'dart:typed_data';

import 'package:zx_tape_player/models/application/hit_model.dart';
import 'package:zx_tape_player/models/application/software_model.dart';
import 'package:zx_tape_player/models/application/term_model.dart';

abstract class BackendService {
  Future<List<TermModel>> getSuggestions(String query);

  Future<List<HitModel>> getHits(String query, int size, {int offset = 0});

  Future<SoftwareModel> getItem(String id);

  Future<SoftwareModel> recognizeTape(String filePath);

  Future<Uint8List> downloadTape(String url);

  Future<String> getExternalUrl(String id);
}
