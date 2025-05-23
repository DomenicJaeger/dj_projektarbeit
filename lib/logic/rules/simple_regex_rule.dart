import 'dart:io';

import 'package:dj_projektarbeit/logic/rules/_eingabe.dart';
import 'package:dj_projektarbeit/logic/rules/_rule.dart';

class SimpleRegexRule extends Rule {
  @override
  final String type;

  @override
  String excelField;

  String regex;

  SimpleRegexRule()
      : type = 'regEx',
        excelField = 'Spalte',
        regex = '';

  SimpleRegexRule.fileName()
      : type = 'fileName',
        excelField = 'Dateiname',
        regex = r'[^\\/]+$';

  SimpleRegexRule.parentDirectory()
      : type = 'parentDirectory',
        excelField = 'Ordnerpfad',
        regex = r'^.*(?=\\[^\\]+$)';

  SimpleRegexRule._({
    required this.type,
    required this.excelField,
    required this.regex,
  });

  @override
  String? apply(File input) {
    final path = input.path;
    final regExp = RegExp(regex, caseSensitive: false, multiLine: true);
    final match = regExp.firstMatch(path);
    return match?.groupCount == 0 ? match?.group(0) : match?.group(1);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'excelField': excelField,
        'regex': regex,
      };

  static SimpleRegexRule fromJson(Map<String, dynamic> json) {
    return SimpleRegexRule._(
      type: json['type'],
      excelField: json['excelField'],
      regex: json['regex'],
    );
  }

  @override
  List<Eingabe> get eingaben => [
        Eingabe(
          label: 'Regex',
          valueType: String,
          value: () => regex,
          setValue: (value) {
            regex = value;
          },
        ),
      ];
}
