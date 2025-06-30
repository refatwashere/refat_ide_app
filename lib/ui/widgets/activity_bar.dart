import 'package:flutter/material.dart';

class ActivityBar extends StatelessWidget {
  final VoidCallback onTerminalToggled;

  const ActivityBar({super.key, required this.onTerminalToggled});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () {},
            tooltip: 'Explorer',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.extension),
            onPressed: () {},
            tooltip: 'Extensions',
          ),
          IconButton(
            icon: const Icon(Icons.developer_mode),
            onPressed: () {},
            tooltip: 'Debug',
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.terminal),
            onPressed: onTerminalToggled,
            tooltip: 'Terminal',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}