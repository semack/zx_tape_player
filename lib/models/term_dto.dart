/// text : "Lode Runner"
/// labeltype : ""
/// type : "SOFTWARE"
/// entry_id : "0002912"

class TermDto {
  String _text;
  String _labeltype;
  String _type;
  String _entryId;

  String get text => _text;
  String get labeltype => _labeltype;
  String get type => _type;
  String get entryId => _entryId;

  TermDto({
      String text, 
      String labeltype, 
      String type, 
      String entryId}){
    _text = text;
    _labeltype = labeltype;
    _type = type;
    _entryId = entryId;
}

  TermDto.fromJson(dynamic json) {
    _text = json["text"];
    _labeltype = json["labeltype"];
    _type = json["type"];
    _entryId = json["entry_id"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["text"] = _text;
    map["labeltype"] = _labeltype;
    map["type"] = _type;
    map["entry_id"] = _entryId;
    return map;
  }

}