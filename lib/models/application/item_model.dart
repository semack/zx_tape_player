class ItemModel {
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
}

class ScreenShotModel{
  final String type;
  final String url;

  ScreenShotModel(this.type, this.url);
}

class AuthorModel {
  final String name;
  final String role;

  AuthorModel(this.name, this.role);
}
