import 'package:sprintf/sprintf.dart';

extension StringFormatExtension on String {
  String format(var arguments) =>  sprintf(this, arguments);
}

extension RmoveAllHtmlTagsExtension on String {
  String removeAllHtmlTags() {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );
    return this.replaceAll(exp, '');
  }
}