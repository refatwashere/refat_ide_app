import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final double width;

  const Sidebar({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('EXPLORER', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          _buildFileItem('lib', Icons.folder),
          _buildFileItem('main.dart', Icons.code),
          _buildFileItem('pubspec.yaml', Icons.settings),
        ],
      ),
    );
  }

  Widget _buildFileItem(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 16),
      title: Text(name),
      dense: true,
    );
  }
}