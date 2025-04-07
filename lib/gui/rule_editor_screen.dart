import 'package:flutter/material.dart';
import '../logic/rule.dart';
import '../logic/rule_type.dart';
import '../logic/rule_config.dart';

class RuleEditorScreen extends StatefulWidget {
  final Rule? existingRule;

  const RuleEditorScreen({super.key, this.existingRule});

  @override
  State<RuleEditorScreen> createState() => _RuleEditorScreenState();
}

class _RuleEditorScreenState extends State<RuleEditorScreen> {
  RuleType? selectedRuleType;
  final Map<String, TextEditingController> _inputControllers = {};

  @override
  void initState() {
    super.initState();

    if (widget.existingRule != null) {
      final rule = widget.existingRule!;
      selectedRuleType = rule.type;

      final config = rule.toConfig();

      if (config.regex != null) {
        _inputControllers['Regex'] = TextEditingController(text: config.regex);
      }
      if (config.index != null) {
        _inputControllers['Position'] = TextEditingController(text: config.index.toString());
      }
      if (config.reverseIndex != null) {
        _inputControllers['Rückwärts-Index'] = TextEditingController(text: config.reverseIndex.toString());
      }

      _inputControllers['Excel Spalte'] = TextEditingController(text: config.excelField);
      _inputControllers['Regelname'] = TextEditingController(text: config.name);
    }
  }

  void _saveRule() {
    if (selectedRuleType == null) return;

    final eingaben = selectedRuleType!.eingaben;
    List<String> values = [];

    for (var eingabe in eingaben) {
      final controller = _inputControllers[eingabe.label];
      if (controller == null || controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bitte alle Felder ausfüllen')),
        );
        return;
      }
      values.add(controller.text.trim());
    }

    final config = selectedRuleType!.configFromInputs(values);
    final rule = selectedRuleType!.createRule(config);

    Navigator.pop(context, rule);
  }

  @override
  Widget build(BuildContext context) {
    final selectedInputs = selectedRuleType?.eingaben ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRule == null ? 'Neue Regel erstellen' : 'Regel bearbeiten'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<RuleType>(
              decoration: InputDecoration(labelText: 'Regeltyp auswählen'),
              value: selectedRuleType,
              items: RuleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRuleType = value;
                  _inputControllers.clear();
                  for (var eingabe in selectedRuleType?.eingaben ?? []) {
                    _inputControllers[eingabe.label] = TextEditingController();
                  }
                });
              },
            ),
            SizedBox(height: 16),
            ...selectedInputs.map((eingabe) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _inputControllers[eingabe.label],
                  decoration: InputDecoration(
                    labelText: eingabe.label,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: eingabe.valueType == 'int' ? TextInputType.number : TextInputType.text,
                ),
              );
            }).toList(),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveRule,
                  child: Text("Speichern"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Abbrechen"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
