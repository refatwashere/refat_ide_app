import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
// import 'package:highlight/languages/dart.dart'; // Removed unused import
import '../../core/services/language_server.dart';
import 'dart:async';

class AdvancedEditorFeatures {
  final CodeController controller;
  final Function(String) onAnalysisComplete;
  final ValueNotifier<List<Diagnostic>> diagnosticsNotifier;
  final ValueNotifier<List<CompletionItem>> completionsNotifier;

  AdvancedEditorFeatures({
    required this.controller,
    required this.onAnalysisComplete,
  }) : diagnosticsNotifier = ValueNotifier([]),
       completionsNotifier = ValueNotifier([]) {
    _init();
  }

  void _init() {
    controller.addListener(_onCodeChanged);
  }

  void dispose() {
    controller.removeListener(_onCodeChanged);
    diagnosticsNotifier.dispose();
    completionsNotifier.dispose();
  }

  void _onCodeChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performAnalysis();
      _updateCompletions();
    });
  }

  Timer? _debounceTimer;

  Future<void> _performAnalysis() async {
    final results = await LanguageServer.analyze(controller.text);
    diagnosticsNotifier.value = results.diagnostics;
    onAnalysisComplete(results.formatted);
  }

  Future<void> _updateCompletions() async {
    final cursorOffset = controller.selection.baseOffset;
    final completions = await LanguageServer.getCompletions(
      controller.text,
      cursorOffset,
      cursorOffset
    );
    completionsNotifier.value = completions;
  }

  Future<void> formatDocument() async {
    final formatted = await LanguageServer.format(controller.text);
    controller.value = controller.value.copyWith(
      text: formatted,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void applyCompletion(CompletionItem item) {
    final cursorOffset = controller.selection.baseOffset;
    final text = controller.text;
    final prefix = text.substring(0, cursorOffset);
    final lastBoundary = prefix.lastIndexOf(RegExp(r'[^\w]')) + 1;
    final startOffset = lastBoundary;
    final endOffset = cursorOffset;
    controller.value = controller.value.replaced(
      TextSelection(baseOffset: startOffset, extentOffset: endOffset),
      item.insertText ?? item.label,
    );
  }

  Widget buildDiagnosticsPanel() {
    return ValueListenableBuilder<List<Diagnostic>>(
      valueListenable: diagnosticsNotifier,
      builder: (context, diagnostics, _) {
        if (diagnostics.isEmpty) {
          return const Center(child: Text('No issues found'));
        }
        
        return ListView.builder(
          itemCount: diagnostics.length,
          itemBuilder: (context, index) {
            final diagnostic = diagnostics[index];
            return ListTile(
              leading: Icon(
                diagnostic.severity == DiagnosticSeverity.error 
                  ? Icons.error 
                  : Icons.warning,
                color: diagnostic.severity == DiagnosticSeverity.error 
                  ? Colors.red 
                  : Colors.orange,
              ),
              title: Text(diagnostic.message),
              subtitle: Text('Line ${diagnostic.range.start.line + 1}'),
              onTap: () {
                // Fallback: place cursor at start of line if 'offset' is not available
                controller.selection = TextSelection.collapsed(
                  offset: 0
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildCompletionsPanel() {
    return ValueListenableBuilder<List<CompletionItem>>(
      valueListenable: completionsNotifier,
      builder: (context, completions, _) {
        if (completions.isEmpty) return const SizedBox();
        
        return Material(
          elevation: 8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              itemCount: completions.length,
              itemBuilder: (context, index) {
                final item = completions[index];
                return ListTile(
                  leading: _completionIcon(item.kind),
                  title: Text(item.label),
                  subtitle: item.detail != null ? Text(item.detail!) : null,
                  onTap: () => applyCompletion(item),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Icon _completionIcon(CompletionItemKind? kind) {
    switch (kind) {
      case CompletionItemKind.method:
        return const Icon(Icons.functions, size: 18);
      case CompletionItemKind.classKind:
        return const Icon(Icons.class_, size: 18);
      case CompletionItemKind.variable:
        return const Icon(Icons.memory, size: 18);
      case CompletionItemKind.property:
        return const Icon(Icons.settings, size: 18);
      default:
        return const Icon(Icons.code, size: 18);
    }
  }
}