import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'core/services/service_integration.dart';
// import 'core/providers/ide_provider.dart';
import 'app.dart';
import 'features/settings/settings_screen.dart';
import 'features/extensions/extension_marketplace.dart';

void main() => runApp(const MobileIDE());

class MobileIDE extends StatelessWidget {
  const MobileIDE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile IDE',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      home: const AppScaffold(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/extensions': (context) => const ExtensionMarketplace(),
      },
    );
  }
}