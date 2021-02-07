/// text : "Vera Cruz"
/// labeltype : ""
/// type : "SOFTWARE"
/// entry_id : "0007160"

class TermDto {
  String text;
  String labeltype;
  String type;
  String entryId;

  static TermDto fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    TermDto termDtoBean = TermDto();
    termDtoBean.text = map['text'];
    termDtoBean.labeltype = map['labeltype'];
    termDtoBean.type = map['type'];
    termDtoBean.entryId = map['entry_id'];
    return termDtoBean;
  }

  Map toJson() => {
    "text": text,
    "labeltype": labeltype,
    "type": type,
    "entry_id": entryId,
  };
}