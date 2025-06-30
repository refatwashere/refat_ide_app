import 'dart:async';
import 'dart:io';
import 'dart:convert';
// import 'package:flutter/foundation.dart';

class TerminalService {
  Process? _process;
  final StreamController<String> _outputController = StreamController.broadcast();
  final List<String> _commandHistory = [];
  int _historyIndex = -1;
  String _currentDirectory = Directory.current.path;

  Stream<String> get output => _outputController.stream;

  Future<void> startTerminal() async {
    try {
      _process = await Process.start(
        Platform.isWindows ? 'cmd' : 'bash',
        [],
        runInShell: true,
        workingDirectory: _currentDirectory,
      );

      _process!.stdout.transform(utf8.decoder).listen((data) {
        _outputController.add(data);
      });

      _process!.stderr.transform(utf8.decoder).listen((data) {
        _outputController.add(data);
      });

      _outputController.add('Mobile IDE Terminal (${_currentDirectory})\$ ');
    } catch (e) {
      _outputController.add('Error starting terminal: $e\n');
    }
  }

  void executeCommand(String command) {
    if (command.trim().isEmpty) return;
    
    _commandHistory.add(command);
    _historyIndex = _commandHistory.length;
    
    if (_process == null) {
      _outputController.add('Terminal not active. Restarting...\n');
      startTerminal();
      return;
    }
    _process!.stdin.writeln(command);
    _outputController.add(command + '\n');
  }

  String getPreviousCommand() {
    if (_commandHistory.isEmpty) return '';
    _historyIndex = _historyIndex > 0 ? _historyIndex - 1 : 0;
    return _commandHistory[_historyIndex];
  }

  String getNextCommand() {
    if (_commandHistory.isEmpty) return '';
    _historyIndex = _historyIndex < _commandHistory.length - 1 
        ? _historyIndex + 1 
        : _commandHistory.length - 1;
    return _commandHistory[_historyIndex];
  }

  void changeDirectory(String path) {
    final newDir = Directory(path);
    if (newDir.existsSync()) {
      _currentDirectory = path;
      if (_process != null) {
        _process!.kill();
      }
      startTerminal();
    } else {
      _outputController.add('Directory not found: $path\n');
    }
  }

  void dispose() {
    _process?.kill();
    _outputController.close();
  }
}