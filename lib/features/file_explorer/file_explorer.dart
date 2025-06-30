import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../core/providers/ide_provider.dart';
import '../../core/services/file_service.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  final Map<String, bool> _expandedState = {};
  String? _contextMenuPath;
  Offset _contextMenuPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final ideProvider = context.watch<IDEProvider>();
    final projectPath = ideProvider.projectPath;

    if (projectPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No project open'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: ideProvider.openProject,
              child: const Text('Open Project'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<FileSystemEntity>>(
      future: FileService.listDir(projectPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entities = snapshot.data!;
        return Stack(
          children: [
            ListView.builder(
              itemCount: entities.length,
              itemBuilder: (context, index) {
                return _buildFileTree(entities[index]);
              },
            ),
            if (_contextMenuPath != null)
              Positioned(
                left: _contextMenuPosition.dx,
                top: _contextMenuPosition.dy,
                child: _buildContextMenu(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFileTree(FileSystemEntity entity) {
    final isDirectory = entity is Directory;
    final name = path.basename(entity.path);
    final expanded = _expandedState[entity.path] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (isDirectory) {
              setState(() {
                _expandedState[entity.path] = !expanded;
              });
            } else {
              context.read<IDEProvider>().openFile(entity.path);
            }
          },
          onSecondaryTapDown: (details) {
            setState(() {
              _contextMenuPath = entity.path;
              _contextMenuPosition = details.globalPosition;
            });
          },
          child: ListTile(
            leading: Icon(isDirectory ? Icons.folder : Icons.insert_drive_file),
            title: Text(name),
            trailing: isDirectory
                ? Icon(expanded ? Icons.expand_less : Icons.expand_more)
                : null,
          ),
        ),
        if (isDirectory && expanded)
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FutureBuilder<List<FileSystemEntity>>(
              future: FileService.listDir(entity.path),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: snapshot.data!
                      .map((child) => _buildFileTree(child))
                      .toList(),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildContextMenu() {
    return Material(
      elevation: 8,
      child: Container(
        width: 200,
        color: Colors.grey[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContextMenuItem(Icons.edit, 'Rename', () => _renameFile()),
            _buildContextMenuItem(Icons.content_copy, 'Copy', () {}),
            _buildContextMenuItem(Icons.delete, 'Delete', () => _deleteFile()),
            const Divider(height: 1, color: Colors.grey),
            _buildContextMenuItem(Icons.create_new_folder, 'New Folder', 
                () => _createNewFolder()),
            _buildContextMenuItem(Icons.note_add, 'New File', 
                () => _createNewFile()),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
        setState(() => _contextMenuPath = null);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }

  void _renameFile() async {
    if (_contextMenuPath == null) return;
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final name = path.basename(_contextMenuPath!);
        return AlertDialog(
          title: const Text('Rename'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: name),
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, name),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
    
    if (newName != null && newName.isNotEmpty) {
      final newPath = path.join(path.dirname(_contextMenuPath!), newName);
      await FileService.rename(_contextMenuPath!, newPath);
      setState(() {});
    }
  }

  void _deleteFile() async {
    if (_contextMenuPath == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete ${path.basename(_contextMenuPath!)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await FileService.delete(_contextMenuPath!);
      setState(() {});
    }
  }

  void _createNewFolder() async {
    final parentDir = _contextMenuPath != null && 
        FileSystemEntity.isDirectorySync(_contextMenuPath!)
      ? _contextMenuPath!
      : path.dirname(_contextMenuPath!);

    final folderName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: const TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'New Folder'),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    if (folderName != null && folderName.isNotEmpty) {
      final newPath = path.join(parentDir, folderName);
      await FileService.createDirectory(newPath);
      setState(() {});
    }
  }

  void _createNewFile() async {
    final parentDir = _contextMenuPath != null && 
        FileSystemEntity.isDirectorySync(_contextMenuPath!)
      ? _contextMenuPath!
      : path.dirname(_contextMenuPath!);

    final fileName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New File'),
        content: const TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'File name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'newfile.txt'),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    if (fileName != null && fileName.isNotEmpty) {
      final newPath = path.join(parentDir, fileName);
      await FileService.createFile(newPath);
      context.read<IDEProvider>().openFile(newPath);
      setState(() {});
    }
  }
}