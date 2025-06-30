import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class IDEProvider extends ChangeNotifier {
  String? _projectPath;
  List<String> _openFiles = [];
  String? _activeFile;
  bool _terminalVisible = false;
  String _currentTheme = 'dark';
  Map<String, dynamic> _editorSettings = {
    'fontSize': 14,
    'fontFamily': 'FiraCode',
    'tabSize': 2,
    'wordWrap': true,
  };

  String? get projectPath => _projectPath;
  List<String> get openFiles => _openFiles;
  String? get activeFile => _activeFile;
  bool get terminalVisible => _terminalVisible;
  String get currentTheme => _currentTheme;
  Map<String, dynamic> get editorSettings => _editorSettings;

  Future<void> openProject() async {
    // TODO: Implement actual file picker integration
    final appDir = await getApplicationDocumentsDirectory();
    _projectPath = path.join(appDir.path, 'projects', 'demo_project');
    notifyListeners();
  }

  void openFile(String filePath) {
    if (!_openFiles.contains(filePath)) {
      _openFiles.add(filePath);
    }
    _activeFile = filePath;
    notifyListeners();
  }

  void closeFile(String filePath) {
    _openFiles.remove(filePath);
    if (_activeFile == filePath) {
      _activeFile = _openFiles.isNotEmpty ? _openFiles.last : null;
    }
    notifyListeners();
  }

  void toggleTerminal() {
    _terminalVisible = !_terminalVisible;
    notifyListeners();
  }

  void setTheme(String themeName) {
    _currentTheme = themeName;
    notifyListeners();
  }

  void updateEditorSetting(String key, dynamic value) {
    _editorSettings[key] = value;
    notifyListeners();
  }
}