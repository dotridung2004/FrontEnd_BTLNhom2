// file: lib/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import 'dart:io';

// Import Models
import 'table/user.dart';
import 'table/home_summary.dart';
import 'table/teaching_schedule.dart';
import 'table/schedule_week_data.dart';
import 'table/report_data.dart';
import 'table/schedule_dropdown_item.dart';
import 'models/student.dart';
import 'models/leave_makeup_summary.dart';
import 'models/pending_makeup_item.dart';
import 'models/leave_history_item.dart';
import 'models/available_schedule.dart';
// Import Models của Sinh viên
import 'models/student_home_summary.dart';
import 'models/student_schedule_item.dart';

// <<< SỬA: Import model Room
import 'models/room.dart';

class ApiService {
  // --- 👇 BẮT ĐẦU SỬA LỖI SINGLETON ---

  // 1. Tạo một thực thể (instance) tĩnh và riêng tư
  static final ApiService _instance = ApiService._internal();

  // 2. Tạo một factory constructor để trả về thực thể đó
  factory ApiService() {
    return _instance;
  }

  // 3. Tạo một constructor riêng tư
  ApiService._internal();

  // --- 👆 KẾT THÚC SỬA LỖI SINGLETON ---

  static const String baseUrl = 'http://10.0.2.2:8000/api';
  String? _token; // Biến này bây giờ sẽ được chia sẻ toàn ứng dụng

  Map<String, String> _getHeaders({bool needsAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// ---------------------------------------------------
  /// 👤 Xác thực (Authentication)
  /// ---------------------------------------------------
  Future<User> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        loginUrl,
        headers: _getHeaders(needsAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // <<< SỬA LỖI 3: Đồng bộ UTF-8 >>>
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final User user = User.fromJson(data['user']);

        if (data['token'] != null) {
          _token = data['token'];
          print("Đăng nhập thành công, Token đã được lưu!");
        } else {
          print("Cảnh báo: Đăng nhập thành công nhưng không nhận được token.");
        }

        // Sửa logic: Chỉ kiểm tra status, role sẽ được kiểm tra ở Flutter
        if (user.status == 'active') {
          return user;
        } else {
          throw Exception('❌ Tài khoản của bạn đã bị vô hiệu hóa.');
        }
      } else {
        return _handleApiError(response, 'Đăng nhập thất bại');
      }
    } catch (e) {
      print("Login Error: $e");
      if (e is Exception) rethrow;
      throw Exception('Không thể kết nối đến máy chủ.');
    }
  }

  /// ---------------------------------------------------
  /// 🏠 Màn hình Trang chủ (Giáo viên)
  /// ---------------------------------------------------
  Future<HomeSummary> fetchHomeSummary(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/home-summary');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        return HomeSummary.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        return _handleApiError(response, 'Lỗi khi tải dữ liệu trang chủ');
      }
    } catch (e) {
      print("fetchHomeSummary Error: $e");
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// 🎓 Màn hình Trang chủ (Sinh viên)
  /// ---------------------------------------------------
  Future<StudentHomeSummary> fetchStudentHomeSummary(int userId) async {
    final Uri url = Uri.parse('$baseUrl/students/$userId/home-summary');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        return StudentHomeSummary.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        return _handleApiError(
            response, 'Lỗi khi tải dữ liệu trang chủ sinh viên');
      }
    } catch (e) {
      print("fetchStudentHomeSummary Error: $e");
      rethrow;
    }
  }

  /// Lấy tất cả lịch học trong tuần cho sinh viên
  Future<List<StudentScheduleItem>> fetchStudentWeeklySchedule(
      int userId) async {
    final Uri url = Uri.parse('$baseUrl/students/$userId/schedule/week');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => StudentScheduleItem.fromJson(item)).toList();
      } else {
        return _handleApiError(response, 'Lỗi khi tải lịch học tuần');
      }
    } catch (e) {
      print("fetchStudentWeeklySchedule Error: $e");
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// 🗓️ Màn hình Lịch dạy (Schedule Screen)
  /// ---------------------------------------------------
  Future<ScheduleWeekData> fetchScheduleData(int userId, int weekOffset) async {
    final Uri url = Uri.parse(
        '$baseUrl/users/$userId/schedule-data?week_offset=$weekOffset');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        return ScheduleWeekData.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        return _handleApiError(response, 'Lỗi khi tải dữ liệu lịch dạy');
      }
    } catch (e) {
      print("fetchScheduleData Error: $e");
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// ✅ Màn hình Điểm danh (Attendance Screen)
  /// ---------------------------------------------------
  Future<List<ScheduleDropdownItem>> fetchSchedulesByDate(
      int userId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url =
    Uri.parse('$baseUrl/users/$userId/schedules-by-date?date=$formattedDate');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => ScheduleDropdownItem.fromJson(item)).toList();
      } else {
        return _handleApiError(response, 'Lỗi khi tải danh sách lớp học');
      }
    } catch (e) {
      print("fetchSchedulesByDate Error: $e");
      rethrow;
    }
  }

  Future<List<Student>> fetchStudentsForSchedule(
      int scheduleId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url = Uri.parse(
        '$baseUrl/schedules/$scheduleId/students-attendance?date=$formattedDate');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body.isEmpty) return [];
        return body.map((item) => Student.fromJson(item)).toList();
      } else {
        return _handleApiError(response, 'Lỗi khi tải danh sách sinh viên');
      }
    } catch (e) {
      print("fetchStudentsForSchedule Error: $e");
      rethrow;
    }
  }

  Future<void> saveAttendanceBulk(
      int scheduleId, DateTime date, List<Student> students) async {
    final payload = {
      'schedule_id': scheduleId,
      'attendances': students
          .map((s) => {
        'student_id': int.tryParse(s.studentId) ?? 0,
        'status': s.statusString,
      })
          .toList(),
    };
    final Uri url = Uri.parse('$baseUrl/attendances/bulk-save');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        _handleApiError(response, 'Lỗi khi lưu điểm danh');
      }
    } catch (e) {
      print("saveAttendanceBulk Error: $e");
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// 📊 Màn hình Báo cáo (Report Screen)
  /// ---------------------------------------------------
  Future<ReportData> fetchReportData(
      int userId, DateTime startDate, DateTime endDate) async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    final Uri url = Uri.parse(
        '$baseUrl/users/$userId/report-data?start_date=$startDateStr&end_date=$endDateStr');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        return ReportData.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        return _handleApiError(response, 'Lỗi khi tải dữ liệu báo cáo');
      }
    } catch (e) {
      print("fetchReportData Error: $e");
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// ⏳ Màn hình Nghỉ/Bù (Leave/Makeup Screen)
  /// ---------------------------------------------------
  Future<LeaveMakeupSummary> fetchLeaveMakeupSummary(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/leave-makeup-summary');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        return LeaveMakeupSummary.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        return _handleApiError(response, 'Lỗi tải tóm tắt nghỉ bù');
      }
    } catch (e) {
      print("fetchLeaveMakeupSummary Error: $e");
      rethrow;
    }
  }

  Future<List<PendingMakeupItem>> fetchPendingMakeupSchedules(
      int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/pending-makeup');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => PendingMakeupItem.fromJson(item)).toList();
      } else {
        return _handleApiError(response, 'Lỗi tải danh sách cần bù');
      }
    } catch (e) {
      print("fetchPendingMakeupSchedules Error: $e");
      rethrow;
    }
  }

  Future<List<LeaveHistoryItem>> fetchLeaveHistory(int userId) async {
    final Uri url = Uri.parse('$baseUrl/users/$userId/leave-history');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => LeaveHistoryItem.fromJson(item)).toList();
      } else {
        return _handleApiError(response, 'Lỗi tải lịch sử nghỉ');
      }
    } catch (e) {
      print("fetchLeaveHistory Error: $e");
      rethrow;
    }
  }

  Future<List<AvailableSchedule>> fetchAvailableSchedulesForLeave(
      int userId) async {
    final Uri url =
    Uri.parse('$baseUrl/users/$userId/available-schedules-for-leave');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => AvailableSchedule.fromJson(item)).toList();
      } else {
        return _handleApiError(response, 'Lỗi tải lịch dạy');
      }
    } catch (e) {
      print("fetchAvailableSchedulesForLeave Error: $e");
      rethrow;
    }
  }

  Future<void> submitLeaveRequest(
      {required int userId,
        required int scheduleId,
        required String reason}) async {
    final Uri url = Uri.parse('$baseUrl/leave-requests');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          // <<< SỬA LỖI 1: THÊM user_id (giống file Laravel Controller)
          'user_id': userId,
          'schedule_id': scheduleId,
          'reason': reason,
        }),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        _handleApiError(response, 'Lỗi gửi yêu cầu nghỉ');
      }
    } catch (e) {
      print("submitLeaveRequest Error: $e");
      rethrow;
    }
  }

  Future<void> submitMakeupRequest(
      {required int userId,
        required int originalScheduleId,
        required DateTime newDate,
        required String newSession,
        required int newRoomId,
        String? note}) async {
    final Uri url = Uri.parse('$baseUrl/makeup-classes');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          // <<< SỬA LỖI 2: THÊM teacher_id (giống file migration)
          'teacher_id': userId,
          'original_schedule_id': originalScheduleId,
          'new_schedule_date': DateFormat('yyyy-MM-dd').format(newDate),
          'new_session': newSession,
          'new_room_id': newRoomId,
          'note': note,
        }),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        _handleApiError(response, 'Lỗi gửi yêu cầu dạy bù');
      }
    } catch (e) {
      print("submitMakeupRequest Error: $e");
      rethrow;
    }
  }

  // <<< SỬA: HÀM MỚI ĐỂ TẢI PHÒNG HỌC >>>
  /// ---------------------------------------------------
  /// 🏫 Quản lý Phòng học (MỚI)
  /// ---------------------------------------------------
  Future<List<Room>> fetchAvailableRooms() async {
    // ❗️ Giả sử endpoint của bạn là '/rooms'.
    // ❗️ Bạn cần thay đổi '/rooms' cho đúng với API backend của bạn.
    final Uri url = Uri.parse('$baseUrl/rooms');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        // <<< SỬA LỖI: Xử lý linh hoạt JSON trả về >>>
        // API có thể trả về:
        // 1. Một List trực tiếp: [...]
        // 2. Một Map được bọc: {'data': [...]} (giống fetchUsers)

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        // Trường hợp 1: API trả về {'data': [...]}
        if (decodedData is Map &&
            decodedData.containsKey('data') &&
            decodedData['data'] is List) {
          final List<dynamic> body = decodedData['data'];
          return body.map((item) => Room.fromJson(item)).toList();
        }
        // Trường hợp 2: API trả về [...]
        else if (decodedData is List) {
          return decodedData.map((item) => Room.fromJson(item)).toList();
        }
        // Trường hợp 3: Định dạng không mong đợi
        else {
          throw Exception('Định dạng dữ liệu phòng học trả về không đúng.');
        }
        // <<< KẾT THÚC SỬA LỖI >>>
      } else {
        return _handleApiError(response, 'Lỗi khi tải danh sách phòng học');
      }
    } catch (e) {
      print("fetchAvailableRooms Error: $e");
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// 🧑‍🤝‍🧑 Quản lý Người dùng (CRUD)
  /// ---------------------------------------------------
  Future<List<User>> fetchUsers() async {
    final Uri url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        if (data['data'] is List) {
          final List<dynamic> body = data['data'];
          return body.map((item) => User.fromJson(item)).toList();
        } else {
          throw Exception('Định dạng dữ liệu trả về không đúng.');
        }
      } else {
        return _handleApiError(response, 'Lỗi khi tải danh sách người dùng');
      }
    } catch (e) {
      print("fetchUsers Error: $e");
      rethrow;
    }
  }

  Future<User> fetchUserById(int id) async {
    final Uri url = Uri.parse('$baseUrl/users/$id');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('❌ Không tìm thấy người dùng');
      } else {
        return _handleApiError(response, 'Lỗi khi tải thông tin người dùng');
      }
    } catch (e) {
      print("fetchUserById Error: $e");
      rethrow;
    }
  }

  Future<void> createUser(User user) async {
    final Uri url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode != 201) {
        _handleApiError(response, 'Lỗi khi tạo user');
      }
    } catch (e) {
      print("createUser Error: $e");
      rethrow;
    }
  }

  Future<void> updateUser(int id, User user) async {
    final Uri url = Uri.parse('$baseUrl/users/$id');
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode != 200) {
        _handleApiError(response, 'Lỗi khi cập nhật user');
      }
    } catch (e) {
      print("updateUser Error: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    final Uri url = Uri.parse('$baseUrl/users/$id');
    try {
      final response = await http.delete(url, headers: _getHeaders());
      if (response.statusCode != 204) {
        _handleApiError(response, 'Xóa user thất bại');
      }
    } catch (e) {
      print("deleteUser Error: $e");
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// ⚙️ Hàm xử lý lỗi API chung (Private Helper)
  /// ---------------------------------------------------
  Never _handleApiError(http.Response response, String defaultMessage) {
    print(
        "API Error (${response.request?.url}): ${response.statusCode} - ${response.body}");
    try {
      // Thử decode bằng utf8 trước
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      // Sửa lỗi: Check message và errors sâu hơn (giống các file trước)
      if (error is Map && error.containsKey('message')) {
        if (error.containsKey('errors')) {
          final errors = error['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(error['message']);
      }
      throw Exception(error.toString());
    } catch (e) {
      // Nếu decode utf8 thất bại (ví dụ: body không phải JSON), dùng message mặc định
      if (e is FormatException) {
        throw Exception('$defaultMessage (Code: ${response.statusCode})');
      }
      // Ném lại lỗi đã được parse (từ try)
      rethrow;
    }
  }
}