import 'dart:convert';
import 'package:http/http.dart' as http;
import 'table/user.dart';

class ApiService {
  // Sửa baseUrl để trỏ vào Docker từ máy ảo Android
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// 📌 Login user (email + password)
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Giả sử API trả về user trong key 'user'
      return User.fromJson(data['user']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? '❌ Đăng nhập thất bại');
    }
  }

  /// 📌 Lấy danh sách users (CRUD)
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {

      // SỬA LỖI MAP/LIST
      // 1. Decode thành Map (vì API trả về dữ liệu phân trang)
      final Map<String, dynamic> data = jsonDecode(response.body);

      // 2. Lấy danh sách user từ key "data"
      final List<dynamic> body = data['data'];

      // 3. Trả về danh sách đã map
      return body.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('❌ Lỗi khi tải danh sách users');
    }
  }

  Future<User> fetchUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API /users/{id} thường trả về user trực tiếp (hoặc trong key 'data')
      // Nếu vẫn lỗi, thử return User.fromJson(data['data']);
      return User.fromJson(data);
    } else {
      throw Exception('❌ Không tìm thấy user');
    }
  }

  Future<void> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? '❌ Lỗi khi tạo user');
    }
  }

  Future<void> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? '❌ Lỗi khi cập nhật user');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode != 204) {
      throw Exception('❌ Xóa user thất bại');
    }
  }
}