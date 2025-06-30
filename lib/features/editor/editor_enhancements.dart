import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/all.dart';

class EditorEnhancements {
  static const Map<String, String> languageExtensions = {
    'dart': 'dart',
    'js': 'javascript',
    'ts': 'typescript',
    'py': 'python',
    'java': 'java',
    'kt': 'kotlin',
    'swift': 'swift',
    'go': 'go',
    'rs': 'rust',
    'c': 'c',
    'cpp': 'cpp',
    'h': 'cpp',
    'cs': 'csharp',
    'html': 'html',
    'css': 'css',
    'json': 'json',
    'yaml': 'yaml',
    'md': 'markdown',
  };

  static CodeController createController(String content, String filePath) {
    final extension = filePath.split('.').last;
    final language = allLanguages[languageExtensions[extension] ?? 'dart'] ?? allLanguages['dart'];
    return CodeController(
      text: content,
      language: language,
      params: const EditorParams(tabSpaces: 2),
    );
  }

  static Map<String, TextStyle> getEditorTheme() {
    return {
      'keyword': const TextStyle(color: Color(0xFF569CD6)),
      'string': const TextStyle(color: Color(0xFFCE9178)),
      'number': const TextStyle(color: Color(0xFFB5CEA8)),
      'comment': const TextStyle(color: Color(0xFF6A9955)),
      'meta': const TextStyle(color: Color(0xFF9CDCFE)),
      'type': const TextStyle(color: Color(0xFF4EC9B0)),
      'class': const TextStyle(color: Color(0xFF4EC9B0)),
      'function': const TextStyle(color: Color(0xFFDCDCAA)),
    };
  }

  static List<PopupMenuEntry<String>> getQuickActionsMenu(
    BuildContext context, 
    CodeController controller
  ) {
    return [
      const PopupMenuItem(
        value: 'format',
        child: Text('Format Document'),
      ),
      const PopupMenuItem(
        value: 'comment',
        child: Text('Toggle Comment'),
      ),
      const PopupMenuItem(
        value: 'duplicate',
        child: Text('Duplicate Line'),
      ),
      const PopupMenuItem(
        value: 'find',
        child: Text('Find'),
      ),
      const PopupMenuItem(
        value: 'replace',
        child: Text('Replace'),
      ),
    ];
  }

  static void handleQuickAction(String action, CodeController controller) {
    final text = controller.text;
    final selection = controller.selection;
    
    switch (action) {
      case 'format':
        // TODO: Implement formatting logic
        break;
      case 'comment':
        final selectedText = selection.textInside(text);
        final commentedText = selectedText.startsWith('//') 
            ? selectedText.replaceAll('\n//', '\n')
            : '//${selectedText.replaceAll('\n', '\n//')}';
        controller.value = controller.value.replaced(
          selection,
          commentedText,
        );
        break;
      case 'duplicate':
        // Duplicate the current line
        final textLines = text.split('\n');
        // Calculate the line index from the text and selection offset
        int offset = selection.start;
        int lineIndex = 0;
        int charCount = 0;
        for (int i = 0; i < textLines.length; i++) {
          if (offset <= charCount + textLines[i].length) {
            lineIndex = i;
            break;
          }
          charCount += textLines[i].length + 1; // +1 for the newline
        }
        if (lineIndex >= 0 && lineIndex < textLines.length) {
          final lineText = textLines[lineIndex];
          textLines.insert(lineIndex + 1, lineText);
          final newText = textLines.join('\n');
          // Place cursor at the start of the duplicated line
          final newOffset = textLines.take(lineIndex + 2).join('\n').length;
          controller.value = controller.value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(offset: newOffset),
          );
        }
        break;
      case 'find':
      case 'replace':
        // TODO: Implement find/replace UI
        break;
    }
  }
}