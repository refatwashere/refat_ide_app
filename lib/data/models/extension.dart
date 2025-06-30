// Extension data model (duplicate for quick access)
class IDEExtension {
  final String id;
  final String name;
  final String version;
  bool enabled;

  IDEExtension({
    required this.id,
    required this.name,
    required this.version,
    this.enabled = false,
  });
}
