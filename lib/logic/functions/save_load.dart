import 'dart:convert';
import 'dart:io';

import 'package:dj_projektarbeit/logic/rule.dart';
import 'package:dj_projektarbeit/logic/rule_type.dart';
import 'package:dj_projektarbeit/logic/rule_config.dart';

Future<void> saveRulesToJson(List<Rule> rules, String filePath) async {
  final jsonList = rules.map((r) {
    return {
      'type': r.type.name,
      'config': r.toConfig().toJson(),
    };
  }).toList();

  final jsonString = jsonEncode(jsonList);
  final file = File(filePath);
  await file.writeAsString(jsonString);
}

Future<List<Rule>> loadRulesFromJson(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) return [];

  final jsonString = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(jsonString);

  return jsonList.map<Rule>((entry) {
    final typeName = entry['type'] as String;
    final configJson = entry['config'] as Map<String, dynamic>;

    final type = RuleType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => throw Exception('Unbekannter Regeltyp: $typeName'),
    );

    final config = RuleConfig.fromJson(configJson);
    return type.createRule(config);
  }).toList();
}
