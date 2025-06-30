
class SecurityManager {
  static const List<String> _blockedCommands = [
    'rm', 'format', 'dd', 'shutdown', 'reboot', 'init', 'mkfs',
    'chmod 777', 'chown', 'mv /', '> /dev/sda', ':(){:|:&};:'
  ];

  static const List<String> _restrictedDirs = [
    '/system', '/proc', '/sys', '/data', '/sdcard/Android'
  ];

  static bool isCommandAllowed(String command, String currentDir) {
    final normalizedCmd = command.trim().toLowerCase();
    
    // Check for blocked commands
    if (_blockedCommands.any((cmd) => normalizedCmd.startsWith(cmd))) {
      return false;
    }
    
    // Check for directory restrictions
    if (_restrictedDirs.any((dir) => currentDir.startsWith(dir))) {
      return false;
    }
    
    // Check for dangerous patterns
    if (normalizedCmd.contains('&&') || 
        normalizedCmd.contains('||') ||
        normalizedCmd.contains(';') ||
        normalizedCmd.contains('`')) {
      return false;
    }
    
    return true;
  }

  static bool validateExtensionManifest(Map<String, dynamic> manifest) {
    try {
      // Required fields
      if (manifest['id'] == null || 
          manifest['name'] == null || 
          manifest['version'] == null) {
        return false;
      }
      
      // Validate ID format
      final id = manifest['id'] as String;
      if (!RegExp(r'^[a-z0-9_]+\.[a-z0-9_]+$').hasMatch(id)) {
        return false;
      }
      
      // Validate version format
      final version = manifest['version'] as String;
      if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
        return false;
      }
      
      // Check for unsafe permissions
      final permissions = manifest['permissions'] as List? ?? [];
      if (permissions.contains('filesystem:write') || 
          permissions.contains('network:*')) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> sanitizeExtensionManifest(Map<String, dynamic> manifest) {
    final sanitized = Map<String, dynamic>.from(manifest);
    
    // Remove potentially dangerous fields
    sanitized.remove('mainProcess');
    sanitized.remove('nativeDependencies');
    sanitized.remove('systemAccess');
    
    // Limit permissions
    final permissions = (sanitized['permissions'] as List? ?? [])
        .where((perm) => [
          'filesystem:read', 
          'editor:completion', 
          'terminal:read'
        ].contains(perm))
        .toList();
    
    sanitized['permissions'] = permissions;
    
    return sanitized;
  }

  static Future<void> runInSandbox(Function fn, [List<dynamic> args = const []]) async {
    // TODO: Implement actual sandbox using FFI or platform channels
    try {
      await fn(args);
    } catch (e) {
      print('Sandboxed execution error: $e');
    }
  }
}