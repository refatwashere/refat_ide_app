import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key});

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final Terminal terminal = Terminal();
  final TerminalController controller = TerminalController();

  @override
  void initState() {
    super.initState();
    _initTerminal();
  }

  void _initTerminal() async {
    terminal.write('Mobile IDE Terminal\r\n');
    terminal.write('\$ ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          color: Colors.grey[900],
          child: Row(
            children: [
              const Text('Terminal'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: TerminalView(
            terminal,
            controller: controller,
            theme: TerminalTheme(
              cursor: Color(0xFF00FF00),
              selection: Color(0xFF6666FF),
              foreground: Color(0xFFE0E0E0),
              background: Color(0xFF1E1E1E),
              black: Color(0xFF000000),
              white: Color(0xFFFFFFFF),
              red: Color(0xFFFF5555),
              green: Color(0xFF50FA7B),
              yellow: Color(0xFFF1FA8C),
              blue: Color(0xFFBD93F9),
              magenta: Color(0xFFFF79C6),
              cyan: Color(0xFF8BE9FD),
              brightBlack: Color(0xFF44475A),
              brightRed: Color(0xFFFF6E6E),
              brightGreen: Color(0xFF69FF94),
              brightYellow: Color(0xFFFFFA65),
              brightBlue: Color(0xFFD6ACFF),
              brightMagenta: Color(0xFFFF92DF),
              brightCyan: Color(0xFFA4FFFF),
              brightWhite: Color(0xFFFFFFFF),
              searchHitBackground: Color(0xFF44475A),
              searchHitBackgroundCurrent: Color(0xFF6272A4),
              searchHitForeground: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ],
    );
  }
}