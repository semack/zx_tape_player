/// took : 9
/// timed_out : false
/// _shards : {"total":1,"successful":1,"skipped":0,"failed":0}
/// hits : {"total":{"value":1862,"relation":"eq"},"max_score":null,"hits":[{"_index":"zxinfo-20210205-105714","_type":"_doc","_id":"0009031","_score":null,"_source":{"originalDayOfRelease":null,"availability":"Available","title":"A B C","releases":[{"publishers":[{"country":"UK","name":"Artic Computing Ltd","labelType":"Company: Publisher/Manager","publisherSeq":1}]}],"originalMonthOfRelease":null,"score":{"score":5,"votes":1},"genreType":"General","additionalDownloads":[{"path":"/pub/sinclair/games-inlays/a/ABC.jpg","size":360968,"format":"Picture (JPG)","language":null,"type":"Cassette inlay"},{"path":"/pub/sinclair/games-info/a/ABC.txt","size":1355,"format":"Document (TXT)","language":"English","type":"Instructions"},{"path":"/pub/sinclair/screens/in-game/a/ABC.gif","size":1199,"format":"Picture (GIF)","language":null,"type":"Running screen"}],"screens":[{"filename":"ABC.gif","size":1199,"format":"Picture (GIF)","type":"Running screen","title":null,"url":"/pub/sinclair/screens/in-game/a/ABC.gif"}],"originalYearOfRelease":1983,"genre":"General: Education","publishers":[{"country":"UK","notes":[],"name":"Artic Computing Ltd","labelType":"Company: Publisher/Manager","publisherSeq":1}],"genreSubType":"Education","machineType":"ZX-Spectrum 48K","authors":[{"country":"UK","groupName":null,"groupType":null,"notes":[],"groupCountry":null,"authorSeq":1,"roles":[],"name":"Chris A. Thornton","labelType":"Person","type":"Creator"}]},"sort":["A B C"]}]}

class ItemsDto {
  int _took;
  bool _timedOut;
  Shards _shards;
  Hits _hits;

  int get took => _took;

  bool get timedOut => _timedOut;

  Shards get shards => _shards;

  Hits get hits => _hits;

  ItemsDto({int took, bool timedOut, Shards shards, Hits hits}) {
    _took = took;
    _timedOut = timedOut;
    _shards = shards;
    _hits = hits;
  }

  ItemsDto.fromJson(dynamic json) {
    _took = json["took"];
    _timedOut = json["timed_out"];
    _shards = json["_shards"] != null ? Shards.fromJson(json["_shards"]) : null;
    _hits = json["hits"] != null ? Hits.fromJson(json["hits"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["took"] = _took;
    map["timed_out"] = _timedOut;
    if (_shards != null) {
      map["_shards"] = _shards.toJson();
    }
    if (_hits != null) {
      map["hits"] = _hits.toJson();
    }
    return map;
  }
}

/// total : {"value":1862,"relation":"eq"}
/// max_score : null
/// hits : [{"_index":"zxinfo-20210205-105714","_type":"_doc","_id":"0009031","_score":null,"_source":{"originalDayOfRelease":null,"availability":"Available","title":"A B C","releases":[{"publishers":[{"country":"UK","name":"Artic Computing Ltd","labelType":"Company: Publisher/Manager","publisherSeq":1}]}],"originalMonthOfRelease":null,"score":{"score":5,"votes":1},"genreType":"General","additionalDownloads":[{"path":"/pub/sinclair/games-inlays/a/ABC.jpg","size":360968,"format":"Picture (JPG)","language":null,"type":"Cassette inlay"},{"path":"/pub/sinclair/games-info/a/ABC.txt","size":1355,"format":"Document (TXT)","language":"English","type":"Instructions"},{"path":"/pub/sinclair/screens/in-game/a/ABC.gif","size":1199,"format":"Picture (GIF)","language":null,"type":"Running screen"}],"screens":[{"filename":"ABC.gif","size":1199,"format":"Picture (GIF)","type":"Running screen","title":null,"url":"/pub/sinclair/screens/in-game/a/ABC.gif"}],"originalYearOfRelease":1983,"genre":"General: Education","publishers":[{"country":"UK","notes":[],"name":"Artic Computing Ltd","labelType":"Company: Publisher/Manager","publisherSeq":1}],"genreSubType":"Education","machineType":"ZX-Spectrum 48K","authors":[{"country":"UK","groupName":null,"groupType":null,"notes":[],"groupCountry":null,"authorSeq":1,"roles":[],"name":"Chris A. Thornton","labelType":"Person","type":"Creator"}]},"sort":["A B C"]}]

class Hits {
  Total _total;
  dynamic _maxScore;
  List<Hits> _hits;
  dynamic _id;
  Source _source;

  Total get total => _total;

  dynamic get maxScore => _maxScore;

  List<Hits> get hits => _hits;

  dynamic get id => _id;

  Source get source => _source;

  Hits(
      {dynamic id,
      Source source,
      Total total,
      dynamic maxScore,
      List<Hits> hits}) {
    _total = total;
    _maxScore = maxScore;
    _hits = hits;
    _id = id;
    _source = source;
  }

  Hits.fromJson(dynamic json) {
    _total = json["total"] != null ? Total.fromJson(json["total"]) : null;
    _source = json["_source"] != null ? Source.fromJson(json["_source"]) : null;
    _maxScore = json["max_score"];
    _id = json["_id"];
    if (json["hits"] != null) {
      _hits = [];
      json["hits"].forEach((v) {
        _hits.add(Hits.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_total != null) {
      map["total"] = _total.toJson();
    }
    map["max_score"] = _maxScore;
    if (_hits != null) {
      map["hits"] = _hits.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// originalDayOfRelease : null
/// availability : "Available"
/// title : "A B C"
/// releases : [{"publishers":[{"country":"UK","name":"Artic Computing Ltd","labelType":"Company: Publisher/Manager","publisherSeq":1}]}]
/// originalMonthOfRelease : null
/// score : {"score":5,"votes":1}
/// genreType : "General"
/// additionalDownloads : [{"path":"/pub/sinclair/games-inlays/a/ABC.jpg","size":360968,"format":"Picture (JPG)","language":null,"type":"Cassette inlay"},{"path":"/pub/sinclair/games-info/a/ABC.txt","size":1355,"format":"Document (TXT)","language":"English","type":"Instructions"},{"path":"/pub/sinclair/screens/in-game/a/ABC.gif","size":1199,"format":"Picture (GIF)","language":null,"type":"Running screen"}]
/// screens : [{"filename":"ABC.gif","size":1199,"format":"Picture (GIF)","type":"Running screen","title":null,"url":"/pub/sinclair/screens/in-game/a/ABC.gif"}]
/// originalYearOfRelease : 1983
/// genre : "General: Education"
/// publishers : [{"country":"UK","notes":[],"name":"Artic Computing Ltd","labelType":"Company: Publisher/Manager","publisherSeq":1}]
/// genreSubType : "Education"
/// machineType : "ZX-Spectrum 48K"
/// authors : [{"country":"UK","groupName":null,"groupType":null,"notes":[],"groupCountry":null,"authorSeq":1,"roles":[],"name":"Chris A. Thornton","labelType":"Person","type":"Creator"}]

class Source {
  dynamic _originalDayOfRelease;
  String _availability;
  String _title;
  List<Releases> _releases;
  dynamic _originalMonthOfRelease;
  Score _score;
  String _genreType;
  List<AdditionalDownloads> _additionalDownloads;
  List<Screens> _screens;
  int _originalYearOfRelease;
  String _genre;
  List<Publishers> _publishers;
  String _genreSubType;
  String _machineType;
  List<Authors> _authors;

  dynamic get originalDayOfRelease => _originalDayOfRelease;

  String get availability => _availability;

  String get title => _title;

  List<Releases> get releases => _releases;

  dynamic get originalMonthOfRelease => _originalMonthOfRelease;

  Score get score => _score;

  String get genreType => _genreType;

  List<AdditionalDownloads> get additionalDownloads => _additionalDownloads;

  List<Screens> get screens => _screens;

  int get originalYearOfRelease => _originalYearOfRelease;

  String get genre => _genre;

  List<Publishers> get publishers => _publishers;

  String get genreSubType => _genreSubType;

  String get machineType => _machineType;

  List<Authors> get authors => _authors;

  Source(
      {dynamic originalDayOfRelease,
      String availability,
      String title,
      List<Releases> releases,
      dynamic originalMonthOfRelease,
      Score score,
      String genreType,
      List<AdditionalDownloads> additionalDownloads,
      List<Screens> screens,
      int originalYearOfRelease,
      String genre,
      List<Publishers> publishers,
      String genreSubType,
      String machineType,
      List<Authors> authors}) {
    _originalDayOfRelease = originalDayOfRelease;
    _availability = availability;
    _title = title;
    _releases = releases;
    _originalMonthOfRelease = originalMonthOfRelease;
    _score = score;
    _genreType = genreType;
    _additionalDownloads = additionalDownloads;
    _screens = screens;
    _originalYearOfRelease = originalYearOfRelease;
    _genre = genre;
    _publishers = publishers;
    _genreSubType = genreSubType;
    _machineType = machineType;
    _authors = authors;
  }

  Source.fromJson(dynamic json) {
    _originalDayOfRelease = json["originalDayOfRelease"];
    _availability = json["availability"];
    _title = json["title"];
    if (json["releases"] != null) {
      _releases = [];
      json["releases"].forEach((v) {
        _releases.add(Releases.fromJson(v));
      });
    }
    _originalMonthOfRelease = json["originalMonthOfRelease"];
    _score = json["score"] != null ? Score.fromJson(json["score"]) : null;
    _genreType = json["genreType"];
    if (json["additionalDownloads"] != null) {
      _additionalDownloads = [];
      json["additionalDownloads"].forEach((v) {
        _additionalDownloads.add(AdditionalDownloads.fromJson(v));
      });
    }
    if (json["screens"] != null) {
      _screens = [];
      json["screens"].forEach((v) {
        _screens.add(Screens.fromJson(v));
      });
    }
    _originalYearOfRelease = json["originalYearOfRelease"];
    _genre = json["genre"];
    if (json["publishers"] != null) {
      _publishers = [];
      json["publishers"].forEach((v) {
        _publishers.add(Publishers.fromJson(v));
      });
    }
    _genreSubType = json["genreSubType"];
    _machineType = json["machineType"];
    if (json["authors"] != null) {
      _authors = [];
      json["authors"].forEach((v) {
        _authors.add(Authors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["originalDayOfRelease"] = _originalDayOfRelease;
    map["availability"] = _availability;
    map["title"] = _title;
    if (_releases != null) {
      map["releases"] = _releases.map((v) => v.toJson()).toList();
    }
    map["originalMonthOfRelease"] = _originalMonthOfRelease;
    if (_score != null) {
      map["score"] = _score.toJson();
    }
    map["genreType"] = _genreType;
    if (_additionalDownloads != null) {
      map["additionalDownloads"] =
          _additionalDownloads.map((v) => v.toJson()).toList();
    }
    if (_screens != null) {
      map["screens"] = _screens.map((v) => v.toJson()).toList();
    }
    map["originalYearOfRelease"] = _originalYearOfRelease;
    map["genre"] = _genre;
    if (_publishers != null) {
      map["publishers"] = _publishers.map((v) => v.toJson()).toList();
    }
    map["genreSubType"] = _genreSubType;
    map["machineType"] = _machineType;
    if (_authors != null) {
      map["authors"] = _authors.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// country : "UK"
/// groupName : null
/// groupType : null
/// notes : []
/// groupCountry : null
/// authorSeq : 1
/// roles : []
/// name : "Chris A. Thornton"
/// labelType : "Person"
/// type : "Creator"

class Authors {
  String _country;
  dynamic _groupName;
  dynamic _groupType;
  List<dynamic> _notes;
  dynamic _groupCountry;
  int _authorSeq;
  List<dynamic> _roles;
  String _name;
  String _labelType;
  String _type;

  String get country => _country;

  dynamic get groupName => _groupName;

  dynamic get groupType => _groupType;

  List<dynamic> get notes => _notes;

  dynamic get groupCountry => _groupCountry;

  int get authorSeq => _authorSeq;

  List<dynamic> get roles => _roles;

  String get name => _name;

  String get labelType => _labelType;

  String get type => _type;

  Authors(
      {String country,
      dynamic groupName,
      dynamic groupType,
      List<dynamic> notes,
      dynamic groupCountry,
      int authorSeq,
      List<dynamic> roles,
      String name,
      String labelType,
      String type}) {
    _country = country;
    _groupName = groupName;
    _groupType = groupType;
    _notes = notes;
    _groupCountry = groupCountry;
    _authorSeq = authorSeq;
    _roles = roles;
    _name = name;
    _labelType = labelType;
    _type = type;
  }

  Authors.fromJson(dynamic json) {
    _country = json["country"];
    _groupName = json["groupName"];
    _groupType = json["groupType"];
    if (json["notes"] != null) {
      _notes = [];
      json["notes"].forEach((v) {
        _notes.add(v);
      });
    }
    _groupCountry = json["groupCountry"];
    _authorSeq = json["authorSeq"];
    if (json["roles"] != null) {
      _roles = [];
      json["roles"].forEach((v) {
        _roles.add(v);
      });
    }
    _name = json["name"];
    _labelType = json["labelType"];
    _type = json["type"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["country"] = _country;
    map["groupName"] = _groupName;
    map["groupType"] = _groupType;
    if (_notes != null) {
      map["notes"] = _notes.map((v) => v.toJson()).toList();
    }
    map["groupCountry"] = _groupCountry;
    map["authorSeq"] = _authorSeq;
    if (_roles != null) {
      map["roles"] = _roles.map((v) => v.toJson()).toList();
    }
    map["name"] = _name;
    map["labelType"] = _labelType;
    map["type"] = _type;
    return map;
  }
}

/// country : "UK"
/// notes : []
/// name : "Artic Computing Ltd"
/// labelType : "Company: Publisher/Manager"
/// publisherSeq : 1

class Publishers {
  String _country;
  List<dynamic> _notes;
  String _name;
  String _labelType;
  int _publisherSeq;

  String get country => _country;

  List<dynamic> get notes => _notes;

  String get name => _name;

  String get labelType => _labelType;

  int get publisherSeq => _publisherSeq;

  Publishers(
      {String country,
      List<dynamic> notes,
      String name,
      String labelType,
      int publisherSeq}) {
    _country = country;
    _notes = notes;
    _name = name;
    _labelType = labelType;
    _publisherSeq = publisherSeq;
  }

  Publishers.fromJson(dynamic json) {
    _country = json["country"];
    if (json["notes"] != null) {
      _notes = [];
      json["notes"].forEach((v) {
        _notes.add(v);
      });
    }
    _name = json["name"];
    _labelType = json["labelType"];
    _publisherSeq = json["publisherSeq"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["country"] = _country;
    if (_notes != null) {
      map["notes"] = _notes.map((v) => v.toJson()).toList();
    }
    map["name"] = _name;
    map["labelType"] = _labelType;
    map["publisherSeq"] = _publisherSeq;
    return map;
  }
}

/// filename : "ABC.gif"
/// size : 1199
/// format : "Picture (GIF)"
/// type : "Running screen"
/// title : null
/// url : "/pub/sinclair/screens/in-game/a/ABC.gif"

class Screens {
  String _filename;
  int _size;
  String _format;
  String _type;
  dynamic _title;
  String _url;

  String get filename => _filename;

  int get size => _size;

  String get format => _format;

  String get type => _type;

  dynamic get title => _title;

  String get url => _url;

  Screens(
      {String filename,
      int size,
      String format,
      String type,
      dynamic title,
      String url}) {
    _filename = filename;
    _size = size;
    _format = format;
    _type = type;
    _title = title;
    _url = url;
  }

  Screens.fromJson(dynamic json) {
    _filename = json["filename"];
    _size = json["size"];
    _format = json["format"];
    _type = json["type"];
    _title = json["title"];
    _url = json["url"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["filename"] = _filename;
    map["size"] = _size;
    map["format"] = _format;
    map["type"] = _type;
    map["title"] = _title;
    map["url"] = _url;
    return map;
  }
}

/// path : "/pub/sinclair/games-inlays/a/ABC.jpg"
/// size : 360968
/// format : "Picture (JPG)"
/// language : null
/// type : "Cassette inlay"

class AdditionalDownloads {
  String _path;
  int _size;
  String _format;
  dynamic _language;
  String _type;

  String get path => _path;

  int get size => _size;

  String get format => _format;

  dynamic get language => _language;

  String get type => _type;

  AdditionalDownloads(
      {String path, int size, String format, dynamic language, String type}) {
    _path = path;
    _size = size;
    _format = format;
    _language = language;
    _type = type;
  }

  AdditionalDownloads.fromJson(dynamic json) {
    _path = json["path"];
    _size = json["size"];
    _format = json["format"];
    _language = json["language"];
    _type = json["type"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["path"] = _path;
    map["size"] = _size;
    map["format"] = _format;
    map["language"] = _language;
    map["type"] = _type;
    return map;
  }
}

/// score : 5
/// votes : 1

class Score {
  double _score;
  int _votes;

  double get score => _score;

  int get votes => _votes;

  Score({double score, int votes}) {
    _score = score;
    _votes = votes;
  }

  Score.fromJson(dynamic json) {
    _score = json["score"] != null ? json["score"].toDouble() : 0;
    _votes = json["votes"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["score"] = _score;
    map["votes"] = _votes;
    return map;
  }
}

/// publishers : [{"country":"UK","name":"Artic Computing Ltd","labelType":"Company: Publisher/Manager","publisherSeq":1}]

class Releases {
  List<Publishers> _publishers;

  List<Publishers> get publishers => _publishers;

  Releases({List<Publishers> publishers}) {
    _publishers = publishers;
  }

  Releases.fromJson(dynamic json) {
    if (json["publishers"] != null) {
      _publishers = [];
      json["publishers"].forEach((v) {
        _publishers.add(Publishers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_publishers != null) {
      map["publishers"] = _publishers.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// value : 1862
/// relation : "eq"

class Total {
  int _value;
  String _relation;

  int get value => _value;

  String get relation => _relation;

  Total({int value, String relation}) {
    _value = value;
    _relation = relation;
  }

  Total.fromJson(dynamic json) {
    _value = json["value"];
    _relation = json["relation"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["value"] = _value;
    map["relation"] = _relation;
    return map;
  }
}

/// total : 1
/// successful : 1
/// skipped : 0
/// failed : 0

class Shards {
  int _total;
  int _successful;
  int _skipped;
  int _failed;

  int get total => _total;

  int get successful => _successful;

  int get skipped => _skipped;

  int get failed => _failed;

  Shards({int total, int successful, int skipped, int failed}) {
    _total = total;
    _successful = successful;
    _skipped = skipped;
    _failed = failed;
  }

  Shards.fromJson(dynamic json) {
    _total = json["total"];
    _successful = json["successful"];
    _skipped = json["skipped"];
    _failed = json["failed"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["total"] = _total;
    map["successful"] = _successful;
    map["skipped"] = _skipped;
    map["failed"] = _failed;
    return map;
  }
}
