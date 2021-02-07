import 'package:sprintf/sprintf.dart';

extension StringFormatExtension on String {
  String format(var arguments) =>  sprintf(this, arguments);
}