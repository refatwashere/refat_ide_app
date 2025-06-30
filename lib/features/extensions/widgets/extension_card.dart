// Extension card widget
import 'package:flutter/material.dart';

class ExtensionCard extends StatelessWidget {
  const ExtensionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Extension Card'),
      ),
    );
  }
}
