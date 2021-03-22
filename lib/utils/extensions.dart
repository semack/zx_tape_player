import 'dart:ui';

import 'package:sprintf/sprintf.dart';

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);
}

extension StringIsNullOrEmptyExtension on String {
  bool isNullOrEmpty() => this == null || this.trim() == '';
}

extension RemoveAllHtmlTagsExtension on String {
  String removeAllHtmlTags() {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return this.replaceAll(exp, '');
  }
}

extension DurationToStringExtension on Duration {
  String toTimeString() {
    return RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
        .firstMatch("$this")
        ?.group(1);
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

extension EncodeStringExtension on String {
  String safeEncode() {
    return Uri.encodeQueryComponent(this.replaceAll('/', ' '));
  }
}
