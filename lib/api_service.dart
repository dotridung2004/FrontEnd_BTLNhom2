import 'dart:convert';
import 'package:http/http.dart' as http;
import 'table/user.dart';

// 👉 THÊM MỚI 2 IMPORTS
import 'table/home_summary.dart';
import 'table/teaching_schedule.dart';


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
      final User user = User.fromJson(data['user']);

      // Logic kiểm tra role và status
      if (user.role == 'teacher' && user.status == 'active') {
        return user;
      } else {
        if (user.role != 'teacher') {
          throw Exception('❌ Chỉ tài khoản giáo viên mới được phép đăng nhập.');
        } else {
          throw Exception('❌ Tài khoản của bạn đã bị vô hiệu hóa.');
        }
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? '❌ Đăng nhập thất bại');
    }
  }

  // --- HÀM MỚI ---
  /// 📌 Lấy dữ liệu tóm tắt cho màn hình Home
  Future<HomeSummary> fetchHomeSummary(int userId) async {
    // Sử dụng endpoint đã thống nhất với backend
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/home-summary'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Dùng model HomeSummary để parse toàn bộ dữ liệu
      return HomeSummary.fromJson(data);
    } else {
      throw Exception('❌ Lỗi khi tải dữ liệu trang chủ');
    }
  }
  // --- KẾT THÚC HÀM MỚI ---


  /// 📌 Lấy danh sách users (CRUD)
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> body = data['data'];
      return body.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('❌ Lỗi khi tải danh sách users');
    }
  }

  Future<User> fetchUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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