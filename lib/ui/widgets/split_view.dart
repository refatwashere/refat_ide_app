// Split view widget
import 'package:flutter/material.dart';

class SplitView extends StatelessWidget {
  const SplitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(color: Colors.grey[200])),
        const VerticalDivider(width: 1),
        Expanded(child: Container(color: Colors.white)),
      ],
    );
  }
}
