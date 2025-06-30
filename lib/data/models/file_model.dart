// File data model
class FileModel {
  final String name;
  final String path;
  final String content;

  FileModel({required this.name, required this.path, this.content = ''});
}
