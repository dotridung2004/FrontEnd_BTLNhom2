// ... (các import và class StudentHomeScreen giữ nguyên) ...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api_service.dart';
import '../models/student_home_summary.dart';
import '../models/student_schedule_item.dart';
import '../table/user.dart'; // Import model User
import 'profile_screen.dart'; // Import màn hình Profile
// (Class StudentHomeScreen giữ nguyên)
class StudentHomeScreen extends StatefulWidget {
  final int userId;
  const StudentHomeScreen({super.key, required this.userId});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;
  final ApiService _apiService = ApiService();

  // 👇 *** THÊM CÁC BIẾN ĐỂ QUẢN LÝ AVATAR ***
  User? _currentUser;
  // 👆 *** KẾT THÚC THÊM BIẾN ***

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      // Trang chủ của Sinh viên
      StudentHomeScreenContent(userId: widget.userId),
      // Các màn hình khác của sinh viên (ví dụ)
      Container(child: Center(child: Text('Lịch học (Sinh viên)'))),
      Container(child: Center(child: Text('Kết quả (Sinh viên)'))),
      // 👇 *** THÊM MÀN HÌNH PROFILE VÀO DANH SÁCH ***
      ProfileScreen(userId: widget.userId), // Dùng chung màn hình Profile
    ];

    // 👇 *** GỌI HÀM LẤY DỮ LIỆU USER ***
    _fetchUserData();
  }

  // --- 👇 CÁC HÀM MỚI ĐỂ LẤY VÀ HIỂN THỊ AVATAR ---

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

  Widget _buildUserAvatar() {
    if (_currentUser == null) {
      // Hiển thị loading nhỏ khi chưa có dữ liệu
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 18, // Kích thước nhỏ hơn một chút cho vừa vặn
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
        radius: 18, // Kích thước nhỏ hơn một chút
        backgroundColor: Colors.blue.shade700,
        backgroundImage: avatar,
        child: avatar == null
            ? Text(
          initial,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        )
            : null,
      ),
    );
  }
  // --- 👆 KẾT THÚC CÁC HÀM MỚI ---

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
          // 👇 *** SỬA LẠI ACTIONS ĐỂ HIỂN THỊ AVATAR ***
          // (Bạn có thể thêm lại icon chuông nếu muốn)
          // Stack( ... icon chuông ... ),
          _buildUserAvatar(),
          // 👆 *** KẾT THÚC SỬA ACTIONS ***
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // 👇 *** CẬP NHẬT BOTTOMNAV CHO SINH VIÊN ***
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch học'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Kết quả'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'), // 👈 THÊM NÚT NÀY
        ],
      ),
    );
  }
}

// --- Nội dung trang chủ của Sinh viên ---
class StudentHomeScreenContent extends StatefulWidget {
  final int userId;
  const StudentHomeScreenContent({super.key, required this.userId});

  @override
  State<StudentHomeScreenContent> createState() => _StudentHomeScreenContentState();
}

class _StudentHomeScreenContentState extends State<StudentHomeScreenContent> {
  final ApiService _apiService = ApiService();
  late Future<StudentHomeSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _apiService.fetchStudentHomeSummary(widget.userId);
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return DateFormat(' (EEEE, dd/MM/yyyy)', 'vi_VN').format(now);
  }

  Color _getStatusColor(String status) {
    if (status == 'Đang diễn ra') return Colors.green;
    if (status == 'Sắp diễn ra') return Colors.orange;
    return Colors.blue; // Mặc định (scheduled)
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentHomeSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Không có dữ liệu.'));
        }

        // --- 👇 SỬA LỖI Ở ĐÂY 👇 ---

        // ✅ Lấy dữ liệu đã parse thành công
        final homeData = snapshot.data!;

        // ⛔️ DÒNG CŨ (SAI):
        // final summary = homeData.summary;

        // ✅ DÒNG MỚI (ĐÚNG):
        // Truy cập trực tiếp vào thuộc tính của homeData
        final schedules = homeData.schedules;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('My Schedule', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            // Thẻ tóm tắt của sinh viên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sử dụng trực tiếp homeData
                SummaryCard(value: homeData.todaySessions.toString(), label: 'Buổi học hôm nay'),
                SummaryCard(value: homeData.weekSessions.toString(), label: 'Buổi học tuần này'),
                SummaryCard(value: '${homeData.attendanceRate.toStringAsFixed(0)}%', label: 'Chuyên cần'),
              ],
            ),
            // --- 👆 KẾT THÚC SỬA LỖI 👆 ---

            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Lịch học hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_getTodayDate(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),

            if (schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(child: Text('🎉 Bạn không có lịch học hôm nay.', style: TextStyle(fontSize: 16, color: Colors.grey))),
              ),

            // Danh sách lịch học
            Column(
              children: [
                for (final schedule in schedules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildStudentScheduleCard(schedule),
                  ),
              ],
            )
          ],
        );
      },
    );
  }

  // Widget thẻ lịch học của sinh viên
  Widget _buildStudentScheduleCard(StudentScheduleItem schedule) {
    final statusColor = _getStatusColor(schedule.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 6)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
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
                  Text(schedule.timeRange, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(schedule.lessons, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(schedule.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(schedule.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(schedule.courseCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Hiển thị Giảng viên và Phòng học
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue.shade800, size: 20),
              const SizedBox(width: 8),
              Text(schedule.teacherName, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.blue.shade800, size: 20),
              const SizedBox(width: 8),
              Text(schedule.location, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Tóm tắt (SummaryCard)
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
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}