import 'package:dj_projektarbeit/gui/preview_screen.dart';
import 'package:dj_projektarbeit/gui/rule_editor_screen.dart';
import 'package:dj_projektarbeit/logic/functions/save_load.dart';
import 'package:dj_projektarbeit/logic/pathfinder.dart';
import 'package:dj_projektarbeit/logic/rule.dart';
import 'package:dj_projektarbeit/logic/root_directory_entry.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<RootDirectoryEntry> directories = [];
  List<Rule> rules = [];

  Future<void> selectDirectory() async {
    final String? selectedDirectory = await getDirectoryPath();
    if (selectedDirectory != null) {
      if (directories.any((dir) => dir.path == selectedDirectory)) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Dieses Verzeichnis wurde bereits hinzugefügt.')));
        return;
      }

      final pathfinder = Pathfinder(selectedDirectory);
      final files = pathfinder.getAllFilePaths();

      setState(() {
        directories.add(RootDirectoryEntry(selectedDirectory, files));
      });
    }
  }

  void removeDirectory(int index) {
    setState(() {
      directories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RegEx Pathfinder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Alle nicht gespeicherten Daten gehen verloren!'),
                          content: Text('Möchten Sie eine neue Instanz starten?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Abbrechen')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Neu starten'),
                            )
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        setState(() {
                          directories.clear();
                          rules.clear();
                        });
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Neue Instanz gestartet')),
                        );
                      }
                    },
                    child: Text("Neu")),
                SizedBox(width: 8),
                ElevatedButton(onPressed: selectDirectory, child: Text("Ordner hinzufügen")),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (directories.isEmpty || rules.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Bitte Verzeichnisse und Regeln anlegen.')));
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewScreen(
                          directories: directories,
                          rules: rules,
                        ),
                      ),
                    );
                  },
                  child: Text("Vorschau"),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  /// ------------------- List of Directories -------------------
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: directories.isEmpty
                          ? Center(child: Text('Noch keine Verzeichnisse hinzugefügt.'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text('Ordnerpfad', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Dateien', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: SizedBox()), // Leerer Platz für Aktionen (Icons)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: directories.length,
                                    itemBuilder: (context, index) {
                                      final dir = directories[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 6, child: Text(dir.path)),
                                            Expanded(flex: 2, child: Text('${dir.fileCount} Dateien')),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () => removeDirectory(index),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: 8),

                  /// ------------------- List of Rules -------------------
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final rule = await Navigator.push<Rule>(
                            context,
                            MaterialPageRoute(builder: (context) => RuleEditorScreen()),
                          );
                          if (rule != null) {
                            setState(() {
                              rules.add(rule);
                            });
                          }
                        },
                        child: Text("Regelsatz hinzufügen"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(onPressed: _saveRules, child: Text("Regelsatz speichern")),
                      SizedBox(width: 8),
                      ElevatedButton(onPressed: _loadRules, child: Text("Regelsatz laden")),
                    ],
                  ),
                  SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: rules.isEmpty
                          ? Center(child: Text("Noch keine Regeln hinzugefügt."))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text('Excel-Spalte', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(
                                          flex: 4,
                                          child: Text('Regelname', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(
                                          flex: 3,
                                          child: Text('Aktionen', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: rules.length,
                                    itemBuilder: (context, index) {
                                      final rule = rules[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 3, child: Text(rule.excelField)),
                                            Expanded(flex: 4, child: Text(rule.name)),
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.arrow_upward),
                                                    onPressed: index > 0 ? () => _moveRule(index, index - 1) : null,
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.arrow_downward),
                                                    onPressed: index < rules.length - 1
                                                        ? () => _moveRule(index, index + 1)
                                                        : null,
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () => _editRule(index),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () => _removeRule(index),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveRules() async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Regeln speichern',
      fileName: 'rules.json',
    );
    if (path != null) {
      await saveRulesToJson(rules, path);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Regeln gespeichert')));
    }
  }

  void _loadRules() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final loadedRules = await loadRulesFromJson(result.files.single.path!);
      setState(() {
        rules = loadedRules;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Regeln geladen')));
    }
  }

  void _moveRule(int oldIndex, int newIndex) {
    setState(() {
      final rule = rules.removeAt(oldIndex);
      rules.insert(newIndex, rule);
    });
  }

  void _editRule(int index) async {
    final editedRule = await Navigator.push<Rule>(
      context,
      MaterialPageRoute(
        builder: (context) => RuleEditorScreen(existingRule: rules[index]),
      ),
    );

    if (editedRule != null) {
      setState(() {
        rules[index] = editedRule;
      });
    }
  }

  void _removeRule(int index) {
    setState(() {
      rules.removeAt(index);
    });
  }
}
