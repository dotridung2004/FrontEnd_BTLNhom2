// lib/screens/home_screen.dart

import 'package:btl_nhom2/api_service.dart';
import 'package:btl_nhom2/table/user.dart';
import 'package:btl_nhom2/screens/profile_screen.dart';
import 'package:btl_nhom2/screens/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'report_screen.dart';
import 'leave_makeup_screen.dart'; // ✅ ĐÃ THÊM DÒNG NÀY
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

    // ✅ ĐÃ SỬA LỖI: Chỉ truyền userId cho ProfileScreen (nếu các màn hình khác không cần)
    _widgetOptions = <Widget>[
      const HomeScreenContent(),
      const ScheduleScreen(),
      const AttendanceScreen(),
      const LeaveMakeupScreen(),
      const ReportScreen(),
      ProfileScreen(userId: widget.userId), // Bỏ const vì userId không phải hằng số
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

// ... (Các widget bên dưới: HomeScreenContent, SummaryCard, ScheduleCard giữ nguyên) ...

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Teaching Schedule', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SummaryCard(value: '6', label: 'Tiết hôm nay'),
            SummaryCard(value: '15', label: 'Tiết tuần này'),
            SummaryCard(value: '0%', label: 'Hoàn thành'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: const [
            Text('Lịch dạy hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(' (Thứ 5, Ngày 18/9/2025)', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        const ScheduleCard(
          time: '7:00 - 9:40',
          lessons: 'Tiết 1-3',
          title: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
          courseCode: '(CSE441_001)',
          location: '210 - B5',
          status: 'Đang diễn ra',
          statusColor: Colors.green,
          borderColor: Colors.green,
        ),
        const SizedBox(height: 16),
        const ScheduleCard(
          time: '9:45 - 12:25',
          lessons: 'Tiết 4-6',
          title: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
          courseCode: '(CSE441_002)',
          location: '207 - B5',
          status: 'Sắp diễn ra',
          statusColor: Colors.orange,
          borderColor: Colors.orange,
        ),
      ],
    );
  }
}


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