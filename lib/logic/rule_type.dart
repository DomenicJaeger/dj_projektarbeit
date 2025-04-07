import 'rule_config.dart';
import 'rule.dart';

enum RuleType {
  fileName(label: 'Dateiname extrahieren', eingaben: []),
  parentDirectory(label: 'Ordnerpfad extrahieren', eingaben: []),
  pathSegment(label: 'Pfadsegment extrahieren', eingaben: [
    Eingabe(label: 'Position', valueType: 'int'),
    Eingabe(label: 'Excel Spalte', valueType: 'String'),
    Eingabe(label: 'Regelname', valueType: 'String'),
  ]),
  reversePathSegment(label: 'Rückwärts-Segment extrahieren', eingaben: [
    Eingabe(label: 'Rückwärts-Index', valueType: 'int'),
    Eingabe(label: 'Excel Spalte', valueType: 'String'),
    Eingabe(label: 'Regelname', valueType: 'String'),
  ]),
  regEx(label: 'Benutzerdefinierter Regex', eingaben: [
    Eingabe(label: 'Regex', valueType: 'String'),
    Eingabe(label: 'Excel Spalte', valueType: 'String'),
    Eingabe(label: 'Regelname', valueType: 'String'),
  ]);

  final String label;
  final List<Eingabe> eingaben;

  const RuleType({required this.label, this.eingaben = const []});
}

class Eingabe {
  final String label;
  final String valueType;

  const Eingabe({required this.label, required this.valueType});
}

class Eingabewert {
  final String value;

  Eingabewert(this.value);
}

extension RuleTypeExtension on RuleType {
  Rule createRule(RuleConfig config) {
    switch (this) {
      case RuleType.fileName:
        return FileNameRule();
      case RuleType.parentDirectory:
        return ParentDirectoryRule();
      case RuleType.pathSegment:
        return PathSegmentRule(
          name: config.name,
          excelField: config.excelField,
          index: config.index ?? 0,
        );
      case RuleType.reversePathSegment:
        return ReversePathSegmentRule(
          name: config.name,
          excelField: config.excelField,
          reverseIndex: config.reverseIndex ?? -1,
        );
      case RuleType.regEx:
        return SimpleRegexRule(
          name: config.name,
          excelField: config.excelField,
          regex: config.regex ?? '',
        );
    }
  }

  RuleConfig configFromInputs(List<String> values) {
    switch (this) {
      case RuleType.fileName:
        return RuleConfig(name: 'Dateiname', excelField: 'Dateiname');
      case RuleType.parentDirectory:
        return RuleConfig(name: 'Ordnerpfad', excelField: 'Ordnerpfad');
      case RuleType.pathSegment:
        return RuleConfig(
          index: int.tryParse(values[0]),
          excelField: values[1],
          name: values[2],
        );
      case RuleType.reversePathSegment:
        return RuleConfig(
          reverseIndex: int.tryParse(values[0]),
          excelField: values[1],
          name: values[2],
        );
      case RuleType.regEx:
        return RuleConfig(
          regex: values[0],
          excelField: values[1],
          name: values[2],
        );
    }
  }
}
