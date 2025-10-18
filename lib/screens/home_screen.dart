import 'package:flutter/material.dart';
import '../widgets/schedule_card.dart';
import '../widgets/summary_card.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Teaching Schedule',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SummaryCard(value: '6', label: 'Tiết hôm nay'),
              SummaryCard(value: '15', label: 'Tiết tuần này'),
              SummaryCard(value: '0%', label: 'Hoàn thành'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Lịch dạy hôm nay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(' (Thứ 5, Ngày 18/9/2025)',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ SỬA LỖI: Thêm tham số onSwitchTab còn thiếu
          ScheduleCard(
            time: '7:00 - 9:40',
            lessons: 'Tiết 1-3',
            title: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
            courseCode: '(CSE441_001)',
            location: '210 - B5',
            status: 'Đang diễn ra',
            statusColor: Colors.green,
            borderColor: Colors.green,
            onSwitchTab: (index) {}, // Cung cấp một hàm rỗng
          ),
          const SizedBox(height: 16),
          // ✅ SỬA LỖI: Thêm tham số onSwitchTab còn thiếu
          ScheduleCard(
            time: '9:45 - 12:25',
            lessons: 'Tiết 4-6',
            title: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
            courseCode: '(CSE441_002)',
            location: '207 - B5',
            status: 'Sắp diễn ra',
            statusColor: Colors.orange,
            borderColor: Colors.orange,
            onSwitchTab: (index) {}, // Cung cấp một hàm rỗng
          ),
        ],
      ),
    );
  }
}
