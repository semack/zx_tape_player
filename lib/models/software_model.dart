import 'dart:io';

import 'package:zx_tape_player/models/enums/file_location.dart';

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
  final Iterable<AuthorModel> authors;
  final Iterable<ScreenShotModel> screenShotUrls;
  final String recognizedTapeFileName;
  final Iterable<FileModel> tapeFiles;

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
      this.recognizedTapeFileName,
      this.tapeFiles);

  static Future<SoftwareModel> createFromFile(
      String filePath, String title) async {
    var file = File(filePath);
    if (await file.exists()) {
      return SoftwareModel(
          null,
          false,
          title,
          null,
          null,
          null,
          null,
          null,
          null,
          <AuthorModel>[],
          <ScreenShotModel>[],
          null,
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
