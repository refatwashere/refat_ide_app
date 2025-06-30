import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/ide_provider.dart';
import 'ui/widgets/activity_bar.dart';
import 'ui/widgets/sidebar.dart';
import 'ui/widgets/status_bar.dart';
import 'features/editor/editor_screen.dart';
import 'features/terminal/terminal_panel.dart';
import 'features/debug/debug_panel.dart';
import 'features/git/git_panel.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  double _sidebarWidth = 200;
  double _terminalHeight = 150;
  int _activeBottomPanel = 0; // 0: terminal, 1: debug, 2: git

  @override
  Widget build(BuildContext context) {
    final ideProvider = context.watch<IDEProvider>();
    final showBottomPanel = ideProvider.terminalVisible;

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                ActivityBar(
                  onTerminalToggled: () => ideProvider.toggleTerminal(),
                ),
                const VerticalDivider(width: 1),
                Sidebar(width: _sidebarWidth),
                const VerticalDivider(width: 1),
                const Expanded(
                  child: EditorScreen(),
                ),
              ],
            ),
          ),
          if (showBottomPanel)
            SizedBox(
              height: _terminalHeight,
              child: _buildBottomPanel(),
            ),
          StatusBar(
            onPanelChanged: (index) => setState(() => _activeBottomPanel = index),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    switch (_activeBottomPanel) {
      case 0:
        return const TerminalPanel();
      case 1:
        return const DebugPanel();
      case 2:
        return const GitPanel();
      default:
        return const TerminalPanel();
    }
  }
}