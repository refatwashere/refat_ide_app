

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../features/extensions/models/extension.dart';

class ExtensionService {
  Future<void> deactivateExtension(IDEExtension extension) async {
    // Deactivate the extension (stop isolate if running)
    final isolate = _extensionIsolates[extension.id];
    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      _extensionIsolates.remove(extension.id);
      print('Extension ${extension.id} deactivated');
    }
  }
  static const String _extensionManifest = 'extension.json';
  final List<IDEExtension> _extensions = [];
  final Map<String, Isolate> _extensionIsolates = {};

  List<IDEExtension> get installedExtensions => _extensions;

  Future<void> loadExtensions() async {
    final extensionsDir = await _getExtensionsDirectory();
    if (!await extensionsDir.exists()) {
      await extensionsDir.create(recursive: true);
    }

    final extensionDirs = extensionsDir.listSync()
      .whereType<Directory>()
      .toList();

    for (final dir in extensionDirs) {
      final manifestFile = File(path.join(dir.path, _extensionManifest));
      if (await manifestFile.exists()) {
        try {
          final manifest = json.decode(await manifestFile.readAsString());
          _extensions.add(IDEExtension.fromJson(manifest));
        } catch (e) {
          print('Error loading extension ${dir.path}: $e');
        }
      }
    }
  }

  Future<void> activateExtension(IDEExtension extension) async {
    if (!extension.enabled) return;
    
    final extensionDir = await _getExtensionDirectory(extension.id);
    final mainScript = File(path.join(extensionDir.path, 'main.js'));
    
    if (await mainScript.exists()) {
      final receivePort = ReceivePort();
      
      try {
        final isolate = await Isolate.spawn(
          _runExtension,
          receivePort.sendPort,
          onError: receivePort.sendPort,
          onExit: receivePort.sendPort,
          paused: true,
        );
        
        _extensionIsolates[extension.id] = isolate;
        
        // Send initialization data to the extension
        receivePort.sendPort.send({
          'type': 'init',
          'id': extension.id,
          'scriptPath': mainScript.path,
        });
        
        isolate.resume(isolate.pauseCapability!);
        
        receivePort.listen((message) {
          _handleExtensionMessage(extension.id, message);
        });
      } catch (e) {
        print('Error activating extension ${extension.id}: $e');
      }
    }
  }

  static void _runExtension(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    
    await for (final message in receivePort) {
      if (message is Map && message['type'] == 'init') {
        // TODO: Load and run the extension script
        print('Extension ${message['id']} initialized');
      }
      // Handle other message types
    }
  }

  void _handleExtensionMessage(String extensionId, dynamic message) {
    print('Message from $extensionId: $message');
    // TODO: Handle extension messages (commands, UI contributions, etc.)
  }

  Future<Directory> _getExtensionsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, 'extensions'));
  }

  Future<Directory> _getExtensionDirectory(String extensionId) async {
    final extensionsDir = await _getExtensionsDirectory();
    return Directory(path.join(extensionsDir.path, extensionId));
  }
}