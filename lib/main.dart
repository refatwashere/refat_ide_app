import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'core/services/service_integration.dart';
// import 'core/providers/ide_provider.dart';
import 'app.dart';
import 'features/settings/settings_screen.dart';
import 'features/extensions/extension_marketplace.dart';



import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runZonedGuarded(
    () => runApp(const MobileIDE()),
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack),
  );
}

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