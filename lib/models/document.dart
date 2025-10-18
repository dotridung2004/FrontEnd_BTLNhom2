class Document {
  int id;
  String title;
  String? filePath;

  Document({
    required this.id,
    required this.title,
    this.filePath,
  });
}
