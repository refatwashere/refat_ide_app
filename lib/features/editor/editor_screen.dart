import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import '../../core/providers/ide_provider.dart';
import '../../core/services/file_service.dart';
import '../../core/performance/optimizations.dart';
import 'editor_enhancements.dart';
import 'advanced_features.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late CodeController _controller;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  AdvancedEditorFeatures? _advancedFeatures;
  bool _showCompletions = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ideProvider = context.watch<IDEProvider>();
    final activeFile = ideProvider.activeFile;
    
    if (activeFile != null && (activeFile != _controller.text)) {
      _loadFile(activeFile);
    }
  }

  Future<void> _loadFile(String filePath) async {
    final content = await PerformanceOptimizer.readFileWithCache(filePath);
    
    if (mounted) {
      setState(() {
        _controller = EditorEnhancements.createController(content, filePath);
        _advancedFeatures?.dispose();
        _advancedFeatures = AdvancedEditorFeatures(
          controller: _controller,
          onAnalysisComplete: (formatted) {
            if (formatted != _controller.text) {
              _controller.text = formatted;
            }
          },
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = CodeController(text: '');
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() => _showCompletions = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _advancedFeatures?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ideProvider = context.watch<IDEProvider>();
    final editorSettings = ideProvider.editorSettings;
    
    return Semantics(
      label: 'Code editor',
      child: ExcludeSemantics(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTabBar(ideProvider),
                Expanded(
                  child: CodeTheme(
                    data: CodeThemeData(styles: EditorEnhancements.getEditorTheme()),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _controller,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontSize: editorSettings['fontSize'].toDouble(),
                          fontFamily: editorSettings['fontFamily'],
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showCompletions && _advancedFeatures != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _advancedFeatures!.buildCompletionsPanel(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(IDEProvider ideProvider) {
    return Container(
      height: 40,
      color: Colors.grey[900],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ideProvider.openFiles.length,
        itemBuilder: (context, index) {
          final filePath = ideProvider.openFiles[index];
          return TabButton(
            label: path.basename(filePath),
            isActive: ideProvider.activeFile == filePath,
            onClose: () => ideProvider.closeFile(filePath),
            onTap: () => ideProvider.openFile(filePath),
          );
        },
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[800] : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(label),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}