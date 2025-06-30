import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CloudService {
  static const String _apiBase = 'https://api.mobile-ide.com/v1';
  static String? _accessToken;

  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_apiBase/auth/login'),
      body: json.encode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      _accessToken = json.decode(response.body)['accessToken'];
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  static Future<void> saveToCloud(String projectId) async {
    if (_accessToken == null) throw Exception('Not authenticated');
    
    final appDir = await getApplicationDocumentsDirectory();
    final projectPath = path.join(appDir.path, 'projects', projectId);
    final projectDir = Directory(projectPath);
    
    if (!await projectDir.exists()) {
      throw Exception('Project not found');
    }

    final zipPath = await _zipProject(projectPath);
    final zipFile = File(zipPath);
    final bytes = await zipFile.readAsBytes();

    final response = await http.post(
      Uri.parse('$_apiBase/projects/$projectId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/zip',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }

  static Future<String> _zipProject(String projectPath) async {
    // TODO: Implement actual zipping logic
    return path.join(projectPath, 'project.zip');
  }

  static Future<void> syncWithGitHub(String repoUrl) async {
    if (_accessToken == null) throw Exception('Not authenticated');
    
    final response = await http.post(
      Uri.parse('$_apiBase/github/sync'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'repository': repoUrl}),
    );

    if (response.statusCode != 200) {
      throw Exception('Sync failed: ${response.statusCode}');
    }
  }

  static Future<void> deployToCloud(String projectId) async {
    if (_accessToken == null) throw Exception('Not authenticated');
    
    final response = await http.post(
      Uri.parse('$_apiBase/deploy/$projectId'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Deployment failed: ${response.statusCode}');
    }
  }
}