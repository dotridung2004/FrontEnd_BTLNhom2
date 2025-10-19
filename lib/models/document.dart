class Document {
  int id;
  String title;
  String? filePath; // Chúng ta sẽ để trống trường này vì API không có

  Document({
    required this.id,
    required this.title,
    this.filePath,
  });

  // ✅ SỬA LỖI: Bổ sung hàm factory 'fromJson' còn thiếu
  // Hàm này dạy cho lớp Document cách "đọc" dữ liệu JSON từ API
  // và tạo ra một đối tượng Document từ dữ liệu đó.
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'], // Lấy giá trị từ khóa 'id' trong JSON
      title: json['title'], // Lấy giá trị từ khóa 'title' trong JSON
    );
  }
}