import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ide_provider.dart';

class StatusBar extends StatefulWidget {
  final ValueChanged<int>? onPanelChanged;
  
  const StatusBar({super.key, this.onPanelChanged});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  int _activePanel = 0;
  final List<String> _panelNames = ['Terminal', 'Debug', 'Git'];

  @override
  Widget build(BuildContext context) {
    final ideProvider = context.watch<IDEProvider>();
    final activeFile = ideProvider.activeFile;
    
    return Container(
      height: 24,
      color: Colors.blueGrey[900],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (activeFile != null) Text(activeFile.split('/').last),
          const Spacer(),
          _buildPanelSelector(),
          const SizedBox(width: 16),
          const Icon(Icons.error_outline, size: 16),
          const SizedBox(width: 8),
          const Text('0 errors'),
          const SizedBox(width: 16),
          const Icon(Icons.warning_amber, size: 16),
          const SizedBox(width: 8),
          const Text('0 warnings'),
          const SizedBox(width: 16),
          Icon(Icons.device_hub, size: 16),
          const SizedBox(width: 4),
          const Text('main'),
        ],
      ),
    );
  }

  Widget _buildPanelSelector() {
    return ToggleButtons(
      isSelected: List.generate(3, (index) => index == _activePanel),
      onPressed: (index) {
        setState(() => _activePanel = index);
        widget.onPanelChanged?.call(index);
      },
      constraints: const BoxConstraints(minWidth: 80),
      children: _panelNames.map((name) => Text(name)).toList(),
    );
  }
}