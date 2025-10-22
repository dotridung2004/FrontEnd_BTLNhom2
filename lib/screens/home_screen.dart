// 👉 THÊM MỚI CÁC IMPORT CẦN THIẾT
import 'package:btl_nhom2/api_service.dart';
import 'package:btl_nhom2/table/home_summary.dart';
import 'package:btl_nhom2/table/teaching_schedule.dart';
import 'package:btl_nhom2/table/user.dart';
import 'package:intl/intl.dart'; // 👈 Cần cho format ngày tháng

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
      // 👇 SỬA LẠI: Truyền userId cho HomeScreenContent
      HomeScreenContent(userId: widget.userId),
      // 👆
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
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
            child: const Text('TLU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thuy Loi', style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('University', style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
          _buildUserAvatar(),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch dạy'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Điểm danh'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Nghỉ/Bù'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Báo cáo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

// ... (Widget SummaryCard và ScheduleCard giữ nguyên) ...


// --- ⬇️ WIDGET ĐƯỢC CẬP NHẬT ⬇️ ---

class HomeScreenContent extends StatefulWidget {
  // 👉 Thêm dòng này để nhận userId
  final int userId;

  const HomeScreenContent({super.key, required this.userId});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  // 👉 Khai báo ApiService và Future
  final ApiService _apiService = ApiService();
  late Future<HomeSummary> _homeSummaryFuture;

  @override
  void initState() {
    super.initState();
    // 👉 Gọi API khi widget được khởi tạo
    _homeSummaryFuture = _apiService.fetchHomeSummary(widget.userId);
  }

  // 👉 Helper để lấy màu dựa trên status
  Color _getStatusColor(String status) {
    if (status == 'Đang diễn ra') return Colors.green;
    if (status == 'Sắp diễn ra') return Colors.orange;
    if (status == 'Đã kết thúc') return Colors.grey;
    return Colors.blue; // Mặc định
  }

  // 👉 Helper để format ngày tháng
  String _getTodayDate() {
    // Note: Cần import 'package:intl/intl.dart';
    // Đặt locale 'vi' để có Thứ
    final now = DateTime.now();
    return DateFormat(' (EEEE, dd/MM/yyyy)', 'vi_VN').format(now);
  }

  @override
  Widget build(BuildContext context) {
    // 👉 Dùng FutureBuilder để xử lý 3 trạng thái: loading, error, success
    return FutureBuilder<HomeSummary>(
      future: _homeSummaryFuture,
      builder: (context, snapshot) {

        // 1. TRẠNG THÁI LOADING (Đang tải)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. TRẠNG THÁI LỖI
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Lỗi tải dữ liệu: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3. TRẠNG THÁI THÀNH CÔNG
        if (!snapshot.hasData) {
          return const Center(child: Text('Không có dữ liệu.'));
        }

        // ✅ Lấy dữ liệu đã parse thành công
        final homeData = snapshot.data!;
        final summary = homeData; // Đổi tên cho ngắn gọn
        final schedules = homeData.schedules;

        // Trả về ListView với dữ liệu động
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Teaching Schedule', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 👇 Dữ liệu động cho SummaryCard
                SummaryCard(
                    value: summary.todayLessons.toString(),
                    label: 'Tiết hôm nay'
                ),
                SummaryCard(
                    value: summary.weekLessons.toString(),
                    label: 'Tiết tuần này'
                ),
                SummaryCard(
                    value: '${summary.completionPercent.toStringAsFixed(0)}%',
                    label: 'Hoàn thành'
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Lịch dạy hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // 👇 Ngày tháng động
                Text(
                    _getTodayDate(),
                    style: const TextStyle(fontSize: 16, color: Colors.grey)
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nếu không có lịch, hiển thị thông báo
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
                      time: schedule.time,
                      lessons: schedule.lessons,
                      title: schedule.title,
                      courseCode: schedule.courseCode,
                      location: schedule.location,
                      status: schedule.status,
                      // 👇 Lấy màu động
                      statusColor: _getStatusColor(schedule.status),
                      borderColor: _getStatusColor(schedule.status),
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

// --- ⬆️ KẾT THÚC SỬA ⬆️ ---


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
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
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
    required this.status,
    required this.statusColor,
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
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)),
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
                  Text(time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(lessons, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(courseCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  Text(location, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Tài liệu', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}