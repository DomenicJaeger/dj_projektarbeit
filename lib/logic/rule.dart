import 'dart:io';
import 'package:dj_projektarbeit/logic/rule_type.dart';
import 'package:dj_projektarbeit/logic/rule_config.dart';

abstract class Rule {
  RuleType get type;
  String get name;
  String get excelField;
  String get regex;
  String? apply(String input);
  Map<String, dynamic> toJson();
  RuleConfig toConfig();
}

class FileNameRule implements Rule {
  @override
  RuleType get type => RuleType.fileName;

  @override
  String get name => 'Dateiname';

  @override
  String get excelField => 'Dateiname';

  @override
  String get regex => r'[^\\/]+$';

  @override
  String? apply(String input) {
    final match = RegExp(regex).firstMatch(input);
    return match?.group(0);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type.name};

  @override
  RuleConfig toConfig() => RuleConfig(name: name, excelField: excelField);
}

class ParentDirectoryRule implements Rule {
  @override
  RuleType get type => RuleType.parentDirectory;

  @override
  String get name => 'Ordnerpfad';

  @override
  String get excelField => 'Ordnerpfad';

  @override
  String get regex => r'^.*(?=\\[^\\]+$)';

  @override
  String? apply(String input) {
    final match = RegExp(regex).firstMatch(input);
    return match?.group(0);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type.name};

  @override
  RuleConfig toConfig() => RuleConfig(name: name, excelField: excelField);
}

class SimpleRegexRule implements Rule {
  final String name;
  final String excelField;
  final String regex;

  SimpleRegexRule({
    required this.name,
    required this.excelField,
    required this.regex,
  });

  @override
  RuleType get type => RuleType.regEx;

  @override
  String? apply(String input) {
    final match = RegExp(regex).firstMatch(input);
    return match?.group(0);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'excelField': excelField,
        'regex': regex,
      };

  @override
  RuleConfig toConfig() => RuleConfig(
        name: name,
        excelField: excelField,
        regex: regex,
      );

  static SimpleRegexRule fromJson(Map<String, dynamic> json) {
    return SimpleRegexRule(
      name: json['name'] ?? '',
      excelField: json['excelField'] ?? '',
      regex: json['regex'] ?? '',
    );
  }
}

class PathSegmentRule implements Rule {
  final String name;
  final String excelField;
  final int index;

  PathSegmentRule({
    required this.name,
    required this.excelField,
    required this.index,
  });

  @override
  RuleType get type => RuleType.pathSegment;

  @override
  String get regex => '';

  @override
  String? apply(String input) {
    final parts = input.split(Platform.pathSeparator);
    if (index < 0 || index >= parts.length) return null;
    return parts[index];
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'excelField': excelField,
        'index': index,
      };

  @override
  RuleConfig toConfig() => RuleConfig(
        name: name,
        excelField: excelField,
        index: index,
      );

  static PathSegmentRule fromJson(Map<String, dynamic> json) {
    return PathSegmentRule(
      name: json['name'] ?? '',
      excelField: json['excelField'] ?? '',
      index: json['index'] ?? 0,
    );
  }
}

class ReversePathSegmentRule implements Rule {
  final String name;
  final String excelField;
  final int reverseIndex;

  ReversePathSegmentRule({
    required this.name,
    required this.excelField,
    required this.reverseIndex,
  });

  @override
  RuleType get type => RuleType.reversePathSegment;

  @override
  String get regex => '';

  @override
  String? apply(String input) {
    final parts = input.split(Platform.pathSeparator);
    final index = parts.length + reverseIndex;
    if (index < 0 || index >= parts.length) return null;
    return parts[index];
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'excelField': excelField,
        'reverseIndex': reverseIndex,
      };

  @override
  RuleConfig toConfig() => RuleConfig(
        name: name,
        excelField: excelField,
        reverseIndex: reverseIndex,
      );

  static ReversePathSegmentRule fromJson(Map<String, dynamic> json) {
    return ReversePathSegmentRule(
      name: json['name'] ?? '',
      excelField: json['excelField'] ?? '',
      reverseIndex: json['reverseIndex'] ?? 0,
    );
  }
}
