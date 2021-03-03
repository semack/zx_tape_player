import 'dart:io';

import 'package:path/path.dart';
import 'package:zx_tape_player/enums/file_location.dart';

class SoftwareModel {
  final bool isRemote;
  final String title;
  final String year;
  final String genre;
  final int votes;
  final double score;
  final String price;
  final String remarks;
  final Iterable<AuthorModel> authors;
  final Iterable<ScreenShotModel> screenShotUrls;
  final Iterable<FileModel> tapeFiles;

  SoftwareModel(
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
      this.tapeFiles);

  static Future<SoftwareModel> createFromFile(String filePath) async {
    var file = File(filePath);
    if (await file.exists()) {
      return SoftwareModel(
          false,
          basenameWithoutExtension(filePath),
          null,
          null,
          null,
          null,
          null,
          null,
          <AuthorModel>[],
          <ScreenShotModel>[],
          <FileModel>[FileModel(FileLocation.file, filePath)]);
    } else
      throw FileSystemException('File not found.');
  }
}

class ScreenShotModel {
  final String type;
  final String url;

  ScreenShotModel(this.type, this.url);
}

class FileModel {
  final FileLocation location;
  final String url;

  FileModel(this.location, this.url);
}

class AuthorModel {
  final String name;
  final String role;

  AuthorModel(this.name, this.role);
}
