// Extension data model (unified with core/services/extension_service.dart)
class IDEExtension {
  final String id;
  final String name;
  final String version;
  final String description;
  final String publisher;
  final List<String> activatesFor;
  bool enabled;

  IDEExtension({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.publisher,
    required this.activatesFor,
    this.enabled = true,
  });

  factory IDEExtension.fromJson(Map<String, dynamic> json) {
    return IDEExtension(
      id: json['id'],
      name: json['name'],
      version: json['version'],
      description: json['description'] ?? '',
      publisher: json['publisher'] ?? 'Unknown',
      activatesFor: List<String>.from(json['activatesFor'] ?? []),
      enabled: json['enabled'] ?? true,
    );
  }
}
