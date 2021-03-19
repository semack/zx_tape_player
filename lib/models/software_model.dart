import 'dart:io';

import 'package:path/path.dart';
import 'package:zx_tape_player/utils/extensions.dart';

class SoftwareModel {
  final String id;
  final bool isRemote;
  final String title;
  final String year;
  final String genre;
  final int votes;
  final double score;
  final String price;
  final String remarks;
  final List<AuthorModel> authors;
  final List<ScreenShotModel> screenShotUrls;
  final String _currentFileName;
  final List<String> tapeFiles;

  int get currentFileIndex {
    var index = -1;
    if (tapeFiles.length > 0) {
      index = 0;
      if (!_currentFileName.isNullOrEmpty()) {
        index = tapeFiles
            .map((file) => basename(file))
            .toList()
            .indexOf(_currentFileName);
        if (index == -1) index = 0;
      }
    }
    return index;
  }

  SoftwareModel(
      this.id,
      this.isRemote,
      this.title,
      this.year,
      this.genre,
      this.votes,
      this.score,
      this.price,
      this.remarks,
      this.authors,
      this.screenShotUrls,
      this._currentFileName,
      this.tapeFiles);

  static Future<SoftwareModel> createFromFile(
      String filePath, String title) async {
    var file = File(filePath);
    if (await file.exists()) {
      return SoftwareModel(null, false, title, null, null, null, null, null,
          null, <AuthorModel>[], <ScreenShotModel>[], null, [filePath]);
    } else
      throw FileSystemException('File not found.');
  }
}

class ScreenShotModel {
  final String type;
  final String url;

  ScreenShotModel(this.type, this.url);
}

class AuthorModel {
  final String name;
  final String role;

  AuthorModel(this.name, this.role);
}
