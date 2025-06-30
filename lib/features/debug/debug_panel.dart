import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ide_provider.dart';

class DebugPanel extends StatefulWidget {
  const DebugPanel({super.key});

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  final List<String> _breakpoints = [];
  bool _isDebugging = false;
  String _debugStatus = 'Ready';

  @override
  Widget build(BuildContext context) {
    final activeFile = context.watch<IDEProvider>().activeFile;
    
    return Column(
      children: [
        _buildDebugToolbar(),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: _buildBreakpointsList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _buildDebugConsole(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebugToolbar() {
    return Container(
      height: 40,
      color: Colors.grey[900],
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isDebugging ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleDebugging,
            tooltip: _isDebugging ? 'Stop Debugging' : 'Start Debugging',
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: _isDebugging ? _pauseDebugging : null,
            tooltip: 'Pause',
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _isDebugging ? _stepOver : null,
            tooltip: 'Step Over',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: _isDebugging ? _stepInto : null,
            tooltip: 'Step Into',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: _isDebugging ? _stepOut : null,
            tooltip: 'Step Out',
          ),
          const SizedBox(width: 16),
          Text(
            _debugStatus,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openDebugSettings,
            tooltip: 'Debug Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBreakpointsList() {
    return ListView.builder(
      itemCount: _breakpoints.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.adjust, size: 16, color: Colors.red),
          title: Text(_breakpoints[index]),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => _removeBreakpoint(_breakpoints[index]),
          ),
        );
      },
    );
  }

  Widget _buildDebugConsole() {
    return Column(
      children: [
        Container(
          height: 30,
          color: Colors.grey[850],
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const Row(
            children: [
              Text('DEBUG CONSOLE'),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Debug output will appear here...',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleDebugging() {
    setState(() {
      _isDebugging = !_isDebugging;
      _debugStatus = _isDebugging ? 'Debugging...' : 'Ready';
    });
  }

  void _pauseDebugging() {
    setState(() {
      _debugStatus = 'Paused';
    });
  }

  void _stepOver() {
    // TODO: Implement step over
  }

  void _stepInto() {
    // TODO: Implement step into
  }

  void _stepOut() {
    // TODO: Implement step out
  }

  void _removeBreakpoint(String breakpoint) {
    setState(() {
      _breakpoints.remove(breakpoint);
    });
  }

  void _openDebugSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Stop on exceptions'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Enable breakpoints'),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const Text('Debugger Port:'),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '8080',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}