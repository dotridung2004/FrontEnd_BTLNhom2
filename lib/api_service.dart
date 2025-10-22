import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Import Models
import 'table/user.dart';
import 'table/home_summary.dart';
import 'table/teaching_schedule.dart'; // Used by HomeSummary and ScheduleWeekData
import 'table/schedule_week_data.dart';
import 'table/report_data.dart';
import 'table/schedule_dropdown_item.dart'; // For Attendance dropdown
import 'models/student.dart';             // For Attendance list

class ApiService {
  // Base URL for the API (Adjust if needed)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// ---------------------------------------------------
  /// 👤 Authentication
  /// ---------------------------------------------------

  /// 📌 Login user (email + password)
  /// Checks if the user is an active teacher.
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
      // Assuming API returns user data under 'user' key
      final User user = User.fromJson(data['user']);

      // --- Role and Status Check ---
      if (user.role == 'teacher' && user.status == 'active') {
        return user;
      } else {
        if (user.role != 'teacher') {
          throw Exception('❌ Chỉ tài khoản giáo viên mới được phép đăng nhập.');
        } else { // Role is teacher, but status is not active
          throw Exception('❌ Tài khoản của bạn đã bị vô hiệu hóa.');
        }
      }
      // --- End Check ---

    } else {
      // Handle login errors (wrong credentials, server issues)
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? '❌ Đăng nhập thất bại (Code: ${response.statusCode})');
      } catch (e) {
        throw Exception('❌ Đăng nhập thất bại (Code: ${response.statusCode})');
      }
    }
  }

  /// ---------------------------------------------------
  /// 🏠 Home Screen
  /// ---------------------------------------------------

  /// 📌 Fetch summary data for the Home screen.
  Future<HomeSummary> fetchHomeSummary(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/home-summary'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return HomeSummary.fromJson(data);
    } else {
      _handleApiError(response, '❌ Lỗi khi tải dữ liệu trang chủ');
    }
  }

  /// ---------------------------------------------------
  /// 🗓️ Schedule Screen
  /// ---------------------------------------------------

  /// 📌 Fetch schedule data for a specific week.
  Future<ScheduleWeekData> fetchScheduleData(int userId, int weekOffset) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/schedule-data?week_offset=$weekOffset'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ScheduleWeekData.fromJson(data);
    } else {
      _handleApiError(response, '❌ Lỗi khi tải dữ liệu lịch dạy');
    }
  }

  /// ---------------------------------------------------
  /// ✅ Attendance Screen
  /// ---------------------------------------------------

  /// 📌 Fetch schedules (for dropdown) for a teacher on a specific date.
  Future<List<ScheduleDropdownItem>> fetchSchedulesByDate(int userId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/schedules-by-date?date=$formattedDate'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ScheduleDropdownItem.fromJson(item)).toList();
    } else {
      _handleApiError(response, '❌ Lỗi khi tải danh sách lớp học');
    }
  }

  /// 📌 Fetch student list and their attendance status for a specific schedule and date.
  Future<List<Student>> fetchStudentsForSchedule(int scheduleId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(
      Uri.parse('$baseUrl/schedules/$scheduleId/students-attendance?date=$formattedDate'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Student.fromJson(item)).toList();
    } else {
      _handleApiError(response, '❌ Lỗi khi tải danh sách sinh viên');
    }
  }

  /// 📌 Save attendance data for multiple students in bulk.
  Future<void> saveAttendanceBulk(int scheduleId, DateTime date, List<Student> students) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final payload = {
      'schedule_id': scheduleId,
      'date': formattedDate,
      'attendances': students.map((s) => {
        'student_id': int.tryParse(s.studentId) ?? 0, // Ensure ID is integer
        'status': s.statusString,
      }).toList(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/attendances/bulk-save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    // Expect 200 OK for successful bulk save
    if (response.statusCode != 200) {
      _handleApiError(response, '❌ Lỗi khi lưu điểm danh');
    }
    // No return value needed on success
  }

  /// ---------------------------------------------------
  /// 📊 Report Screen
  /// ---------------------------------------------------

  /// 📌 Fetch report data based on user ID and date range.
  Future<ReportData> fetchReportData(int userId, DateTime startDate, DateTime endDate) async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/report-data?start_date=$startDateStr&end_date=$endDateStr'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ReportData.fromJson(data);
    } else {
      _handleApiError(response, '❌ Lỗi khi tải dữ liệu báo cáo');
    }
  }


  /// ---------------------------------------------------
  /// 🧑‍🤝‍🧑 User Management (CRUD - Example)
  /// ---------------------------------------------------

  /// 📌 Fetch a paginated list of users.
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      // Assuming pagination, data is under 'data' key
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> body = data['data'];
      return body.map((item) => User.fromJson(item)).toList();
    } else {
      _handleApiError(response, '❌ Lỗi khi tải danh sách users');
    }
  }

  /// 📌 Fetch a single user by ID.
  Future<User> fetchUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      // Assuming API returns the user object directly
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('❌ Không tìm thấy user');
    }
    else {
      _handleApiError(response, '❌ Lỗi khi tải thông tin user');
    }
  }

  /// 📌 Create a new user.
  Future<void> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()), // Use toJson() from User model
    );
    // Expect 201 Created status
    if (response.statusCode != 201) {
      _handleApiError(response, '❌ Lỗi khi tạo user');
    }
  }

  /// 📌 Update an existing user.
  Future<void> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 200) {
      _handleApiError(response, '❌ Lỗi khi cập nhật user');
    }
  }

  /// 📌 Delete a user.
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    // Expect 204 No Content status
    if (response.statusCode != 204) {
      // Note: 204 response has no body
      throw Exception('❌ Xóa user thất bại (Code: ${response.statusCode})');
    }
  }


  /// ---------------------------------------------------
  /// ⚙️ Private Helper for Error Handling
  /// ---------------------------------------------------

  /// Parses JSON error message from response or throws a default message.
  Never _handleApiError(http.Response response, String defaultMessage) {
    try {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? '$defaultMessage (Code: ${response.statusCode})');
    } catch (e) {
      // If response body is not valid JSON or doesn't have 'message'
      throw Exception('$defaultMessage (Code: ${response.statusCode})');
    }
  }
} // End of ApiService class