class RuleConfig {
  final String name;
  final String excelField;
  final String? regex;
  final int? index;
  final int? reverseIndex;

  RuleConfig({
    required this.name,
    required this.excelField,
    this.regex,
    this.index,
    this.reverseIndex,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'excelField': excelField,
        if (regex != null) 'regex': regex,
        if (index != null) 'index': index,
        if (reverseIndex != null) 'reverseIndex': reverseIndex,
      };

  static RuleConfig fromJson(Map<String, dynamic> json) => RuleConfig(
        name: json['name'],
        excelField: json['excelField'],
        regex: json['regex'],
        index: json['index'],
        reverseIndex: json['reverseIndex'],
      );
}
