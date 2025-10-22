import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import 'dart:io'; // Bỏ comment nếu dùng upload file

// Import Models (Đảm bảo đường dẫn chính xác)
import 'table/user.dart';
import 'table/home_summary.dart';
import 'table/teaching_schedule.dart'; // Dùng bởi HomeSummary và ScheduleWeekData
import 'table/schedule_week_data.dart';
import 'table/report_data.dart';
import 'table/schedule_dropdown_item.dart'; // Dùng cho dropdown Điểm danh
import 'models/student.dart';             // Dùng cho danh sách Điểm danh
import 'models/leave_makeup_summary.dart'; // Cần import khi thêm hàm nghỉ/bù
import 'models/pending_makeup_item.dart'; // Cần import khi thêm hàm nghỉ/bù
import 'models/leave_history_item.dart'; // Cần import khi thêm hàm nghỉ/bù
import 'models/available_schedule.dart'; // Cần import khi thêm hàm nghỉ/bù


class ApiService {
  // Base URL cho API (Điều chỉnh nếu cần)
  // Dùng 10.0.2.2 khi chạy trên máy ảo Android để trỏ về localhost của máy thật
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // TODO: Thêm header Authorization nếu API yêu cầu
  // private String? _token; // Biến lưu token
  // Map<String, String> _getHeaders() {
  //   final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
  //   if (_token != null) {
  //     headers['Authorization'] = 'Bearer $_token';
  //   }
  //   return headers;
  // }


  /// ---------------------------------------------------
  /// 👤 Xác thực (Authentication)
  /// ---------------------------------------------------

  /// 📌 Đăng nhập người dùng (email + password)
  Future<User> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final User user = User.fromJson(data['user']);

        // TODO: Lưu token sau khi đăng nhập thành công
        // if (data['token'] != null) {
        //   _token = data['token'];
        //   // (Lưu token vào SecureStorage nếu cần)
        // }

        // --- Kiểm tra vai trò và trạng thái ---
        if (user.role == 'teacher' && user.status == 'active') {
          return user; // Đăng nhập thành công
        } else {
          if (user.role != 'teacher') {
            throw Exception('❌ Chỉ tài khoản giáo viên mới được phép đăng nhập.');
          } else { // Vai trò đúng nhưng trạng thái không phải 'active'
            throw Exception('❌ Tài khoản của bạn đã bị vô hiệu hóa.');
          }
        }
        // --- Kết thúc kiểm tra ---

      } else {
        _handleApiError(response, 'Đăng nhập thất bại');
      }
    } catch (e) {
      print("Login Error: $e"); // Log lỗi để debug
      if (e is Exception) rethrow; // Ném lại lỗi đã biết
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.');
    }
  }

  /// ---------------------------------------------------
  /// 🏠 Màn hình Trang chủ (Home Screen)
  /// ---------------------------------------------------

  Future<HomeSummary> fetchHomeSummary(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/home-summary');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return HomeSummary.fromJson(data);
      } else {
        _handleApiError(response, 'Lỗi khi tải dữ liệu trang chủ');
      }
    } catch (e) {
      print("fetchHomeSummary Error: $e");
      throw Exception('Không thể tải dữ liệu trang chủ.');
    }
  }

  /// ---------------------------------------------------
  /// 🗓️ Màn hình Lịch dạy (Schedule Screen)
  /// ---------------------------------------------------

  Future<ScheduleWeekData> fetchScheduleData(int userId, int weekOffset) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/schedule-data?week_offset=$weekOffset');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ScheduleWeekData.fromJson(data);
      } else {
        _handleApiError(response, 'Lỗi khi tải dữ liệu lịch dạy');
      }
    } catch (e) {
      print("fetchScheduleData Error: $e");
      throw Exception('Không thể tải dữ liệu lịch dạy.');
    }
  }

  /// ---------------------------------------------------
  /// ✅ Màn hình Điểm danh (Attendance Screen)
  /// ---------------------------------------------------

  Future<List<ScheduleDropdownItem>> fetchSchedulesByDate(int userId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url = Uri.parse('$baseUrl/users/$userId/schedules-by-date?date=$formattedDate');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ScheduleDropdownItem.fromJson(item)).toList();
      } else {
        _handleApiError(response, 'Lỗi khi tải danh sách lớp học');
      }
    } catch (e) {
      print("fetchSchedulesByDate Error: $e");
      throw Exception('Không thể tải danh sách lớp học.');
    }
  }

  Future<List<Student>> fetchStudentsForSchedule(int scheduleId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url = Uri.parse('$baseUrl/schedules/$scheduleId/students-attendance?date=$formattedDate');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        if (body.isEmpty) return [];
        return body.map((item) => Student.fromJson(item)).toList();
      } else {
        _handleApiError(response, 'Lỗi khi tải danh sách sinh viên');
      }
    } catch (e) {
      print("fetchStudentsForSchedule Error: $e");
      throw Exception('Không thể tải danh sách sinh viên.');
    }
  }

  Future<void> saveAttendanceBulk(int scheduleId, DateTime date, List<Student> students) async {
    // final formattedDate = DateFormat('yyyy-MM-dd').format(date); // Bỏ date nếu backend không cần
    final payload = {
      'schedule_id': scheduleId,
      // 'date': formattedDate,
      'attendances': students.map((s) => {
        'student_id': int.tryParse(s.studentId) ?? 0,
        'status': s.statusString,
      }).toList(),
    };
    final Uri url = Uri.parse('$baseUrl/attendances/bulk-save');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, // TODO: Thêm _getHeaders()
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        _handleApiError(response, 'Lỗi khi lưu điểm danh');
      }
    } catch (e) {
      print("saveAttendanceBulk Error: $e");
      throw Exception('Không thể lưu điểm danh.');
    }
  }

  /// ---------------------------------------------------
  /// 📊 Màn hình Báo cáo (Report Screen)
  /// ---------------------------------------------------
  Future<ReportData> fetchReportData(int userId, DateTime startDate, DateTime endDate) async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    final Uri url = Uri.parse('$baseUrl/users/$userId/report-data?start_date=$startDateStr&end_date=$endDateStr');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ReportData.fromJson(data);
      } else {
        _handleApiError(response, 'Lỗi khi tải dữ liệu báo cáo');
      }
    } catch (e) {
      print("fetchReportData Error: $e");
      throw Exception('Không thể tải dữ liệu báo cáo.');
    }
  }

  /// ---------------------------------------------------
  /// ⏳ Màn hình Nghỉ/Bù (Leave/Makeup Screen)
  /// ---------------------------------------------------

  /// 📌 Lấy tóm tắt số buổi nghỉ/cần bù
  Future<LeaveMakeupSummary> fetchLeaveMakeupSummary(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/leave-makeup-summary');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        return LeaveMakeupSummary.fromJson(jsonDecode(response.body));
      } else {
        _handleApiError(response, 'Lỗi tải tóm tắt nghỉ bù');
      }
    } catch (e) {
      print("fetchLeaveMakeupSummary Error: $e");
      throw Exception('Không thể tải tóm tắt nghỉ bù.');
    }
  }

  /// 📌 Lấy danh sách các buổi học cần bù
  Future<List<PendingMakeupItem>> fetchPendingMakeupSchedules(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/pending-makeup');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => PendingMakeupItem.fromJson(item)).toList();
      } else {
        _handleApiError(response, 'Lỗi tải danh sách cần bù');
      }
    } catch (e) {
      print("fetchPendingMakeupSchedules Error: $e");
      throw Exception('Không thể tải danh sách cần bù.');
    }
  }

  /// 📌 Lấy lịch sử nghỉ dạy
  Future<List<LeaveHistoryItem>> fetchLeaveHistory(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/leave-history');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => LeaveHistoryItem.fromJson(item)).toList();
      } else {
        _handleApiError(response, 'Lỗi tải lịch sử nghỉ');
      }
    } catch (e) {
      print("fetchLeaveHistory Error: $e");
      throw Exception('Không thể tải lịch sử nghỉ.');
    }
  }

  /// 📌 Lấy lịch dạy sắp tới (cho dropdown đăng ký nghỉ)
  Future<List<AvailableSchedule>> fetchAvailableSchedulesForLeave(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/available-schedules-for-leave');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => AvailableSchedule.fromJson(item)).toList();
      } else {
        _handleApiError(response, 'Lỗi tải lịch dạy');
      }
    } catch (e) {
      print("fetchAvailableSchedulesForLeave Error: $e");
      throw Exception('Không thể tải lịch dạy.');
    }
  }

  /// 📌 Gửi yêu cầu đăng ký nghỉ
  Future<void> submitLeaveRequest({
    required int userId, // Backend nên lấy từ token
    required int scheduleId,
    required String reason,
    // File? document, // Dành cho upload file
  }) async {
    final Uri url = Uri.parse('$baseUrl/leave-requests');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, // TODO: Thêm _getHeaders()
        body: jsonEncode({
          // 'teacher_id': userId, // Backend nên tự lấy từ token
          'schedule_id': scheduleId,
          'reason': reason,
        }),
      );
      if (response.statusCode != 201) { // 201 Created
        _handleApiError(response, 'Lỗi gửi yêu cầu nghỉ');
      }
    } catch (e) {
      print("submitLeaveRequest Error: $e");
      throw Exception('Không thể gửi yêu cầu nghỉ.');
    }
  }

  /// 📌 Gửi yêu cầu đăng ký dạy bù
  Future<void> submitMakeupRequest({
    required int userId, // Backend nên lấy từ token
    required int originalScheduleId,
    required DateTime newDate,
    required String newSession,
    required int newRoomId,
    String? note,
  }) async {
    final Uri url = Uri.parse('$baseUrl/makeup-classes');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, // TODO: Thêm _getHeaders()
        body: jsonEncode({
          // 'teacher_id': userId, // Backend nên tự lấy từ token
          'original_schedule_id': originalScheduleId,
          'new_schedule_date': DateFormat('yyyy-MM-dd').format(newDate),
          'new_session': newSession,
          'new_room_id': newRoomId,
          'note': note,
        }),
      );
      if (response.statusCode != 201) { // 201 Created
        _handleApiError(response, 'Lỗi gửi yêu cầu dạy bù');
      }
    } catch (e) {
      print("submitMakeupRequest Error: $e");
      throw Exception('Không thể gửi yêu cầu dạy bù.');
    }
  }

  /// ---------------------------------------------------
  /// 🧑‍🤝‍🧑 Quản lý Người dùng (CRUD)
  /// ---------------------------------------------------

  /// 📌 Lấy danh sách người dùng (có phân trang).
  Future<List<User>> fetchUsers() async {
    final Uri url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['data'] is List) {
          final List<dynamic> body = data['data'];
          return body.map((item) => User.fromJson(item)).toList();
        } else {
          throw Exception('Định dạng dữ liệu trả về không đúng.');
        }
      } else {
        _handleApiError(response, 'Lỗi khi tải danh sách người dùng');
      }
    } catch (e) {
      print("fetchUsers Error: $e");
      throw Exception('Không thể tải danh sách người dùng.');
    }
  }

  /// 📌 Lấy thông tin một người dùng theo ID.
  Future<User> fetchUserById(int id) async {
    final Uri url = Uri.parse('$baseUrl/users/$id');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('❌ Không tìm thấy người dùng');
      } else {
        _handleApiError(response, 'Lỗi khi tải thông tin người dùng');
      }
    } catch (e) {
      print("fetchUserById Error: $e");
      throw Exception('Không thể tải thông tin người dùng.');
    }
  }

  /// 📌 Tạo người dùng mới.
  Future<void> createUser(User user) async {
    final Uri url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, // TODO: Thêm _getHeaders()
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode != 201) {
        _handleApiError(response, 'Lỗi khi tạo user');
      }
    } catch (e) {
      print("createUser Error: $e");
      throw Exception('Không thể tạo user.');
    }
  }

  /// 📌 Cập nhật người dùng.
  Future<void> updateUser(int id, User user) async {
    final Uri url = Uri.parse('$baseUrl/users/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, // TODO: Thêm _getHeaders()
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode != 200) {
        _handleApiError(response, 'Lỗi khi cập nhật user');
      }
    } catch (e) {
      print("updateUser Error: $e");
      throw Exception('Không thể cập nhật user.');
    }
  }

  /// 📌 Xóa người dùng.
  Future<void> deleteUser(int id) async {
    final Uri url = Uri.parse('$baseUrl/users/$id');
    try {
      final response = await http.delete(url, headers: {'Accept': 'application/json'}); // TODO: Thêm _getHeaders()
      if (response.statusCode != 204) { // 204 No Content
        _handleApiError(response, 'Xóa user thất bại');
      }
    } catch (e) {
      print("deleteUser Error: $e");
      throw Exception('Không thể xóa user.');
    }
  }

  /// ---------------------------------------------------
  /// ⚙️ Hàm xử lý lỗi API chung (Private Helper)
  /// ---------------------------------------------------

  Never _handleApiError(http.Response response, String defaultMessage) {
    print("API Error (${response.request?.url}): ${response.statusCode} - ${response.body}"); // Log lỗi chi tiết
    try {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? '$defaultMessage (Code: ${response.statusCode})');
    } catch (e) {
      // Ném lỗi với status code nếu body không phải JSON
      throw Exception('$defaultMessage (Code: ${response.statusCode})');
    }
  }

} // Kết thúc lớp ApiService