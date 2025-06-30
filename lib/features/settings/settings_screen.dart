import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ide_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ideProvider = context.watch<IDEProvider>();
    final editorSettings = ideProvider.editorSettings;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: ideProvider.currentTheme == 'dark',
            onChanged: (value) {
              ideProvider.setTheme(value ? 'dark' : 'light');
            },
          ),
          const Divider(),
          _buildSectionHeader('Editor'),
          ListTile(
            title: const Text('Font Size'),
            trailing: DropdownButton<int>(
              value: editorSettings['fontSize'],
              items: [12, 14, 16, 18, 20].map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('$size'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ideProvider.updateEditorSetting('fontSize', value);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Font Family'),
            trailing: DropdownButton<String>(
              value: editorSettings['fontFamily'],
              items: ['FiraCode', 'RobotoMono', 'SourceCodePro', 'CourierNew']
                  .map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ideProvider.updateEditorSetting('fontFamily', value);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Tab Size'),
            trailing: DropdownButton<int>(
              value: editorSettings['tabSize'],
              items: [2, 4, 6, 8].map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('$size spaces'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ideProvider.updateEditorSetting('tabSize', value);
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Word Wrap'),
            value: editorSettings['wordWrap'],
            onChanged: (value) {
              ideProvider.updateEditorSetting('wordWrap', value);
            },
          ),
          const Divider(),
          _buildSectionHeader('Terminal'),
          SwitchListTile(
            title: const Text('Enable Bell Sound'),
            value: editorSettings['terminalBell'],
            onChanged: (value) {
              ideProvider.updateEditorSetting('terminalBell', value);
            },
          ),
          ListTile(
            title: const Text('Default Shell'),
            trailing: DropdownButton<String>(
              value: editorSettings['defaultShell'],
              items: ['bash', 'zsh', 'sh', 'cmd'].map((shell) {
                return DropdownMenuItem(
                  value: shell,
                  child: Text(shell),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ideProvider.updateEditorSetting('defaultShell', value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}