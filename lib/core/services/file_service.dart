import 'dart:io';

class FileService {
  static Future<List<FileSystemEntity>> listDir(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      return dir.list().toList();
    } catch (e) {
      print('Error listing directory: $e');
      return [];
    }
  }

  static Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      return file.readAsString();
    } catch (e) {
      print('Error reading file: $e');
      return '';
    }
  }

  static Future<void> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      print('Error writing file: $e');
    }
  }

  static Future<void> createDirectory(String path) async {
    try {
      await Directory(path).create(recursive: true);
    } catch (e) {
      print('Error creating directory: $e');
    }
  }

  static Future<void> createFile(String path) async {
    try {
      await File(path).create(recursive: true);
    } catch (e) {
      print('Error creating file: $e');
    }
  }

  static Future<void> rename(String oldPath, String newPath) async {
    try {
      await File(oldPath).rename(newPath);
    } catch (e) {
      print('Error renaming file: $e');
    }
  }

  static Future<void> delete(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.file) {
        await File(path).delete();
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      }
    } catch (e) {
      print('Error deleting: $e');
    }
  }
}