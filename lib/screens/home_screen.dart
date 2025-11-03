// 👉 THÊM MỚI CÁC IMPORT CẦN THIẾT
import 'package:btl_nhom2/api_service.dart';
import 'package:btl_nhom2/table/home_summary.dart';
import 'package:btl_nhom2/table/teaching_schedule.dart';
import 'package:btl_nhom2/table/user.dart';
import 'package:intl/intl.dart'; // 👈 Cần cho format ngày tháng
import 'package:btl_nhom2/utils/schedule_utils.dart'; // <<< MỚI 1: Import file tiện ích

// --- Các import cũ ---
import 'package:btl_nhom2/screens/profile_screen.dart';
import 'package:btl_nhom2/screens/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'report_screen.dart';
import 'leave_makeup_screen.dart';
import 'attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  final ApiService _apiService = ApiService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      HomeScreenContent(userId: widget.userId),
      ScheduleScreen(userId: widget.userId),
      AttendanceScreen(userId: widget.userId),
      LeaveAndMakeupScreen(userId: widget.userId),
      ReportScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await _apiService.fetchUserById(widget.userId);
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải thông tin user: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildUserAvatar() {
    if (_currentUser == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          child: SizedBox(
            width: 16,
            height: 16,
            child:
            CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
      );
    }

    final avatar = (_currentUser!.avatarUrl?.isNotEmpty ?? false)
        ? NetworkImage(_currentUser!.avatarUrl!)
        : null;

    final String initial = _currentUser!.name.isNotEmpty
        ? _currentUser!.name[0].toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CircleAvatar(
        backgroundColor: Colors.blue.shade700,
        backgroundImage: avatar,
        child: avatar == null
            ? Text(
          initial,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.shade800,
            child: const Text('TLU',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thuy Loi',
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const Text('University',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_none, color: Colors.grey[800], size: 30),
              Positioned(
                top: 12,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
          _buildUserAvatar(),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Lịch dạy'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline), label: 'Điểm danh'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Nghỉ/Bù'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Báo cáo'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

// --- WIDGET NỘI DUNG TRANG CHỦ ---

class HomeScreenContent extends StatefulWidget {
  final int userId;
  const HomeScreenContent({super.key, required this.userId});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final ApiService _apiService = ApiService();
  late Future<HomeSummary> _homeSummaryFuture;
  late final String _todayDateString;

  @override
  void initState() {
    super.initState();
    _homeSummaryFuture = _apiService.fetchHomeSummary(widget.userId);
    _todayDateString = _getTodayDate();
  }

  // <<< SỬA 1: Cập nhật hàm lấy màu sắc
  // Helper để lấy màu dựa trên status (từ API)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue; // Màu xanh dương cho "Theo lịch"
      case 'cancelled':
        return Colors.red; // Màu đỏ cho "Đã hủy"
      case 'ongoing': // Trạng thái đang diễn ra (nếu có)
        return Colors.green;
      case 'upcoming': // Trạng thái sắp diễn ra (nếu có)
        return Colors.orange;
      case 'finished': // Trạng thái đã kết thúc (nếu có)
        return Colors.grey;
      default:
        return Colors.blue; // Mặc định
    }
  }

  // <<< SỬA 2: Thêm hàm dịch trạng thái
  /// Dịch trạng thái từ API (tiếng Anh) sang tiếng Việt
  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Theo lịch';
      case 'cancelled':
        return 'Đã hủy';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'finished':
        return 'Đã kết thúc';
      default:
        return status; // Trả về nguyên bản nếu không khớp
    }
  }

  // Helper để format ngày tháng
  String _getTodayDate() {
    final now = DateTime.now();
    return DateFormat(' (EEEE, dd/MM/yyyy)', 'vi_VN').format(now);
  }

  // Hàm chuyển đổi chuỗi "4-6" thành giờ "9h45-12h25"
  String _convertLessonsToTime(String lessonString) {
    // Input: "4-6" hoặc "4"
    if (lessonString.isEmpty) return "N/A";

    List<int> lessons = [];
    try {
      if (lessonString.contains('-')) {
        // Case: "4-6"
        final parts = lessonString.split('-');
        final int start = int.parse(parts[0].trim());
        final int end = int.parse(parts[1].trim());
        if (end < start) return lessonString; // Lỗi, trả về chuỗi gốc
        for (int i = start; i <= end; i++) {
          lessons.add(i);
        }
      } else {
        // Case: "4"
        lessons.add(int.parse(lessonString.trim()));
      }

      if (lessons.isEmpty) return lessonString; // Lỗi, trả về chuỗi gốc

      // Gọi hàm từ ScheduleUtils để lấy giờ
      return ScheduleUtils.getLessonTimeRange(lessons);
    } catch (e) {
      debugPrint('Lỗi parse chuỗi tiết học: $e');
      return lessonString; // Nếu lỗi, trả về chuỗi gốc
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeSummary>(
      future: _homeSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Lỗi tải dữ liệu: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Không có dữ liệu.'));
        }

        final homeData = snapshot.data!;
        final summary = homeData;
        final schedules = homeData.schedules;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Lịch trình giảng dạy',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryCard(
                    value: summary.todayLessons.toString(),
                    label: 'Tiết hôm nay'),
                SummaryCard(
                    value: summary.weekLessons.toString(),
                    label: 'Tiết tuần này'),
                SummaryCard(
                    value: '${summary.completionPercent.toStringAsFixed(0)}%',
                    label: 'Hoàn thành'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Lịch dạy hôm nay',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_todayDateString,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            if (schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    '🎉 Bạn không có lịch dạy hôm nay.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),

            // 👇 Dùng Column + for-loop để tạo danh sách ScheduleCard
            Column(
              children: [
                for (final schedule in schedules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ScheduleCard(
                      time: _convertLessonsToTime(schedule.time),
                      lessons: 'Tiết ${schedule.lessons}',
                      title: schedule.title,
                      courseCode: schedule.courseCode,
                      location: schedule.location,

                      // <<< SỬA 3: Truyền dữ liệu đã dịch và màu chính xác
                      status: _translateStatus(schedule.status), // Dịch sang T.Việt
                      statusColor: _getStatusColor(schedule.status), // Lấy màu từ status gốc
                      borderColor: _getStatusColor(schedule.status), // Lấy màu từ status gốc
                    ),
                  ),
              ],
            )
          ],
        );
      },
    );
  }
}

// --- CÁC WIDGET HỖ TRỢ ---

class SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  const SummaryCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 22,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String time, lessons, title, courseCode, location, status;
  final Color statusColor, borderColor;

  const ScheduleCard({
    super.key,
    required this.time,
    required this.lessons,
    required this.title,
    required this.courseCode,
    required this.location,
    required this.status, // Bây giờ sẽ nhận 'Theo lịch', 'Đã hủy', v.v.
    required this.statusColor, // Sẽ nhận Colors.blue, Colors.red, v.v.
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Đây là 'time' (đã được chuyển đổi)
                  Text(time,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  // Đây là 'lessons' (đã thêm chữ "Tiết")
                  Text(lessons, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // Dùng màu nền nhạt
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  status, // Hiển thị status đã được dịch
                  style: TextStyle(
                      color: statusColor, // Dùng màu đậm cho chữ
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(courseCode,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  Text(location,
                      style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Tài liệu',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}