import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/extension_service.dart' as ext_service;
import '../../features/extensions/models/extension.dart';
// Your IDEProvider class definition here
// import '../../core/providers/ide_provider.dart';
class IDEProvider extends ChangeNotifier {
  // existing fields and methods

  // Add this
  late ext_service.ExtensionService _extensionService;

  ext_service.ExtensionService get extensionService => _extensionService;

  IDEProvider() {
    _extensionService = ext_service.ExtensionService();
  }
}

class ExtensionMarketplace extends StatefulWidget {
  const ExtensionMarketplace({super.key});

  @override
  State<ExtensionMarketplace> createState() => _ExtensionMarketplaceState();
}

class _ExtensionMarketplaceState extends State<ExtensionMarketplace> {
  final TextEditingController _searchController = TextEditingController();
  List<IDEExtension> _displayedExtensions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExtensions();
  }

  Future<void> _loadExtensions() async {
    final extensionService = context.read<IDEProvider>().extensionService;
    await extensionService.loadExtensions();
    if (mounted) {
      setState(() {
        _displayedExtensions = extensionService.installedExtensions.cast<IDEExtension>();
        _isLoading = false;
      });
    }
  }

  void _searchExtensions(String query) {
    final extensionService = context.read<IDEProvider>().extensionService;
    if (query.isEmpty) {
      setState(() {
        _displayedExtensions = extensionService.installedExtensions.cast<IDEExtension>();
      });
      return;
    }

    setState(() {
      _displayedExtensions = extensionService.installedExtensions
          .where((ext) => ext.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search extensions...',
            border: InputBorder.none,
          ),
          onChanged: _searchExtensions,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExtensions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildExtensionList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInstallExtensionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExtensionList() {
    if (_displayedExtensions.isEmpty) {
      return const Center(child: Text('No extensions found'));
    }
    
    return ListView.builder(
      itemCount: _displayedExtensions.length,
      itemBuilder: (context, index) {
        return _buildExtensionCard(_displayedExtensions[index]);
      },
    );
  }

  Widget _buildExtensionCard(IDEExtension extension) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(Icons.extension, size: 40),
        title: Text(extension.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(extension.description),
            const SizedBox(height: 4),
            Text('Version: ${extension.version} • ${extension.publisher}'),
          ],
        ),
        trailing: Switch(
          value: extension.enabled,
          onChanged: (value) => _toggleExtension(extension, value),
        ),
        onTap: () => _showExtensionDetails(extension),
      ),
    );
  }

  void _toggleExtension(IDEExtension extension, bool enable) {
    final extensionService = context.read<IDEProvider>().extensionService;
    setState(() {
      extension.enabled = enable;
    });
    if (enable) {
      extensionService.activateExtension(extension);
    } else {
      extensionService.deactivateExtension(extension);
    }
  }

  void _showExtensionDetails(IDEExtension extension) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(extension.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(extension.description),
            const SizedBox(height: 16),
            Text('Publisher: ${extension.publisher}'),
            Text('Version: ${extension.version}'),
            const SizedBox(height: 16),
            Text('Supported Languages: ${extension.activatesFor.join(", ")}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInstallExtensionDialog(BuildContext context) {
    final TextEditingController _installController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install Extension'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter extension ID or URL:'),
            const SizedBox(height: 16),
            TextField(
              controller: _installController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'publisher.extension-id',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement extension installation
              // Example: installExtension(_installController.text);
              Navigator.pop(context);
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }
}

// Remove duplicate IDEExtension class definition from here. Use the one from models/extension.dart

