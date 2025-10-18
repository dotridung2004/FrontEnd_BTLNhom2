import 'package:btl_nhom2/screens/profile_screen.dart';
import 'package:btl_nhom2/screens/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'report_screen.dart'; // BƯỚC 1: Import trang report_screen
import 'main_wrapper.dart';
import 'profile_screen.dart';
import 'leave_makeup_screen.dart';
import 'attendance_screen.dart';
// BƯỚC 2: Chuyển Widget thành StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // BƯỚC 3: Tạo biến state để lưu vị trí tab đang được chọn
  int _selectedIndex = 0;

  // BƯỚC 4: Tạo một danh sách các Widget tương ứng với các tab
  // Tab 'Báo cáo' (vị trí 4) sẽ hiển thị ReportScreen()
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(), // Màn hình chính (tách ra để code gọn hơn)
    ScheduleScreen(),
    AttendanceScreen(),
    LeaveMakeupScreen(),
    ReportScreen(), // Màn hình báo cáo
    ProfileScreen(),
  ];

  // BƯỚC 5: Tạo hàm xử lý khi một tab được nhấn
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật lại vị trí tab
    });
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      // BƯỚC 6: Hiển thị Widget tương ứng với tab được chọn
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        // BƯỚC 7: Cập nhật các thuộc tính của BottomNavigationBar
        currentIndex: _selectedIndex, // Mục đang được chọn
        onTap: _onItemTapped, // Hàm xử lý khi nhấn
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

// Widget chứa nội dung của màn hình chính (trước đây nằm trong body)
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


// --- CÁC WIDGET PHỤ KHÔNG THAY ĐỔI ---
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