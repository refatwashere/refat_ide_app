import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ide_provider.dart';
// import '../services/file_service.dart';
import '../services/terminal_service.dart';
import '../services/extension_service.dart';

Future<void> initializeServices(BuildContext context) async {
  final ideProvider = Provider.of<IDEProvider>(context, listen: false);

  // Initialize terminal service (if needed)
  TerminalService(); // If your TerminalService requires initialization, do it here
  // terminalService.start();

  // Load extensions
  final extensionService = ExtensionService();
  await extensionService.loadExtensions();
  for (final extension in extensionService.installedExtensions) {
    if (extension.enabled) {
      await extensionService.activateExtension(extension);
    }
  }

  // Set service references in provider (if you have these methods)
  // ideProvider.setTerminalService(terminalService);
  // ideProvider.setExtensionService(extensionService);

  // Open demo project on startup
  ideProvider.openProject();
}

class ServiceProvider extends StatelessWidget {
  final Widget child;
  
  const ServiceProvider({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future(() => initializeServices(context)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}