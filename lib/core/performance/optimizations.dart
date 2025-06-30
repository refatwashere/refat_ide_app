import 'dart:async';
import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../services/file_service.dart';

class PerformanceOptimizer {
  static final Map<String, String> _fileCache = {};
  static final Map<String, List<FileSystemEntity>> _directoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static Future<String> readFileWithCache(String filePath) async {
    if (_fileCache.containsKey(filePath)) {
      final lastModified = await File(filePath).lastModified();
      if (_cacheTimestamps[filePath] == lastModified) {
        return _fileCache[filePath]!;
      }
    }
    
    final content = await FileService.readFile(filePath);
    final lastModified = await File(filePath).lastModified();
    
    _fileCache[filePath] = content;
    _cacheTimestamps[filePath] = lastModified;
    
    return content;
  }

  static Future<List<FileSystemEntity>> listDirWithCache(String dirPath) async {
    if (_directoryCache.containsKey(dirPath)) {
      return _directoryCache[dirPath]!;
    }
    
    final entities = await FileService.listDir(dirPath);
    _directoryCache[dirPath] = entities;
    
    // Schedule cache invalidation after 30 seconds
    Timer(const Duration(seconds: 30), () {
      _directoryCache.remove(dirPath);
    });
    
    return entities;
  }

  static Future<void> searchInFiles(String query) async {
    final receivePort = ReceivePort();
    final appDir = await getApplicationDocumentsDirectory();
    final projectDir = path.join(appDir.path, 'projects', 'demo_project');
    
    await Isolate.spawn(_isolatedSearch, {
      'sendPort': receivePort.sendPort,
      'projectPath': projectDir,
      'query': query,
    });
    
    receivePort.listen((results) {
      print('Search results: $results');
      // Update UI with search results
    });
  }

  static void _isolatedSearch(Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    final projectPath = params['projectPath'] as String;
    final query = params['query'] as String;
    final results = <String, List<String>>{};
    
    await for (final entity in Directory(projectPath).list(recursive: true)) {
      if (entity is File) {
        try {
          final content = await entity.readAsString();
          if (content.contains(query)) {
            final lines = content.split('\n');
            final matches = lines
                .asMap()
                .entries
                .where((e) => e.value.contains(query))
                .map((e) => 'Line ${e.key + 1}: ${e.value}')
                .toList();
            
            results[entity.path] = matches;
          }
        } catch (e) {
          print('Error reading ${entity.path}: $e');
        }
      }
    }
    
    sendPort.send(results);
  }

  static Future<void> clearCache() async {
    _fileCache.clear();
    _directoryCache.clear();
    _cacheTimestamps.clear();
  }
}