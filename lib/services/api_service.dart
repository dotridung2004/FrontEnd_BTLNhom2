import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document.dart';

class ApiService {
  // Địa chỉ cơ sở của API
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Hàm để lấy danh sách tài liệu
  Future<List<Document>> fetchDocuments() async {
    // Tạo URL đầy đủ
    final response = await http.get(Uri.parse('$_baseUrl/posts'));

    // Kiểm tra xem cuộc gọi có thành công không (mã 200)
    if (response.statusCode == 200) {
      // Chuyển đổi chuỗi JSON thành một danh sách các đối tượng Map
      final List<dynamic> jsonData = jsonDecode(response.body);

      // Sử dụng hàm fromJson đã tạo ở trên để chuyển đổi từng Map thành một đối tượng Document
      return jsonData.map((json) => Document.fromJson(json)).toList();
    } else {
      // Nếu có lỗi, ném ra một ngoại lệ
      throw Exception('Failed to load documents');
    }
  }

// (Trong tương lai, bạn có thể thêm các hàm khác ở đây như:
// Future<void> addDocument(Document doc) { ... }
// Future<void> deleteDocument(int id) { ... }
//)
}
