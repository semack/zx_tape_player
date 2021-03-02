import 'dart:io';

import 'package:path/path.dart';

class ItemModel {
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
  final Iterable<String> tapeFiles;

  ItemModel(
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

  static Future<ItemModel> createFromFile(String filePath) async {
    var file = File(filePath);
    if (await file.exists()) {
      return ItemModel(
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
          <String>[filePath]);
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
