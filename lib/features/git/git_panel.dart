import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Removed unused import
// import '../../core/providers/ide_provider.dart'; // Removed unused import

class GitPanel extends StatefulWidget {
  const GitPanel({super.key});

  @override
  State<GitPanel> createState() => _GitPanelState();
}

class _GitPanelState extends State<GitPanel> {
  final List<String> _changedFiles = [
    'lib/main.dart (modified)',
    'pubspec.yaml (modified)',
    'assets/icon.png (added)',
    'README.md (deleted)',
  ];
  final List<String> _branches = ['main', 'feature/login', 'bugfix/issue-42'];
  String _currentBranch = 'main';
  String _commitMessage = '';

  @override
  Widget build(BuildContext context) {
    // final projectPath = context.watch<IDEProvider>().projectPath; // Removed unused variable
    
    return Column(
      children: [
        _buildGitToolbar(),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: _buildChangedFiles(),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _buildCommitPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGitToolbar() {
    return Container(
      height: 40,
      color: Colors.grey[900],
      child: Row(
        children: [
          DropdownButton<String>(
            value: _currentBranch,
            items: _branches.map((branch) {
              return DropdownMenuItem(
                value: branch,
                child: Text(branch),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _currentBranch = value);
              }
            },
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchChanges,
            tooltip: 'Fetch Changes',
          ),
          IconButton(
            icon: const Icon(Icons.publish),
            onPressed: _pushChanges,
            tooltip: 'Push Changes',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'View History',
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _commitChanges,
            icon: const Icon(Icons.check),
            label: const Text('Commit'),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildChangedFiles() {
    return ListView.builder(
      itemCount: _changedFiles.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(_changedFiles[index]),
          value: true,
          onChanged: (value) {},
          secondary: Icon(
            _changedFiles[index].contains('(modified)')
                ? Icons.edit
                : _changedFiles[index].contains('(added)')
                    ? Icons.add
                    : Icons.delete,
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildCommitPanel() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Commit message...',
              ),
              onChanged: (value) => _commitMessage = value,
            ),
          ),
        ),
        Container(
          height: 100,
          color: Colors.grey[850],
          padding: const EdgeInsets.all(8),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Changes to be committed:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('M  lib/main.dart'),
              Text('M  pubspec.yaml'),
              Text('A  assets/icon.png'),
              Text('D  README.md'),
            ],
          ),
        ),
      ],
    );
  }

  void _fetchChanges() {
    // TODO: Implement git fetch
  }

  void _pushChanges() {
    // TODO: Implement git push
  }

  void _commitChanges() {
    if (_commitMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a commit message')),
      );
      return;
    }
    
    // TODO: Implement git commit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Committed changes: $_commitMessage')),
    );
    setState(() {
      _changedFiles.clear();
      _commitMessage = '';
    });
  }

  void _showHistory() {
    // TODO: Implement git log viewer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Commit History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Commit $index'),
                subtitle: Text('Author: Developer ${index + 1}\nDate: 2023-06-${15 - index}'),
              );
            },
          ),
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