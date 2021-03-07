/// entry_id : "0001920"
/// title : "Future Knight"
/// file : {"filename":"Future Knight (1986)(Gremlin Graphics)(48K-128K)[a].tzx","md5":"fc6789550463628bcd41156041db67df"}

class FileCheckDto {
  String _entryId;
  String _title;
  FileItem _file;

  String get entryId => _entryId;

  String get title => _title;

  FileItem get file => _file;

  FileCheckDto({String entryId, String title, FileItem file}) {
    _entryId = entryId;
    _title = title;
    _file = file;
  }

  FileCheckDto.fromJson(dynamic json) {
    _entryId = json["entry_id"];
    _title = json["title"];
    _file = json["file"] != null ? FileItem.fromJson(json["file"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["entry_id"] = _entryId;
    map["title"] = _title;
    if (_file != null) {
      map["file"] = _file.toJson();
    }
    return map;
  }
}

/// filename : "Future Knight (1986)(Gremlin Graphics)(48K-128K)[a].tzx"
/// md5 : "fc6789550463628bcd41156041db67df"

class FileItem {
  String _filename;
  String _md5;

  String get filename => _filename;

  String get md5 => _md5;

  FileItem({String filename, String md5}) {
    _filename = filename;
    _md5 = md5;
  }

  FileItem.fromJson(dynamic json) {
    _filename = json["filename"];
    _md5 = json["md5"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["filename"] = _filename;
    map["md5"] = _md5;
    return map;
  }
}
