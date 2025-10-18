import 'package:flutter/material.dart';
import '../widgets/schedule_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isTodayView = false; // Bắt đầu với view Tuần này
  int _selectedDateIndex = 3; // Ngày 18 được chọn

  final List<Map<String, String>> _weekDates = [
    {'day': 'T2', 'date': '15'},
    {'day': 'T3', 'date': '16'},
    {'day': 'T4', 'date': '17'},
    {'day': 'T5', 'date': '18'},
    {'day': 'T6', 'date': '19'},
    {'day': 'T7', 'date': '20'},
    {'day': 'CN', 'date': '21'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopToggle(),
          _isTodayView ? _buildTodayView() : _buildWeekView(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: const [
                ScheduleCard(
                  time: '7:00 - 9:40',
                  lessons: 'Tiết 1-3',
                  title: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
                  courseCode: '(CSE441_001)',
                  location: '210 - B5',
                  status: 'Đang diễn ra',
                  statusColor: Colors.green,
                  borderColor: Colors.green,
                ),
                SizedBox(height: 16),
                ScheduleCard(
                  time: '9:45 - 12:25',
                  lessons: 'Tiết 4-6',
                  title: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
                  courseCode: '(CSE441_002)',
                  location: '207 - B5',
                  status: 'Sắp diễn ra',
                  statusColor: Colors.orange,
                  borderColor: Colors.orange,
                ),
                SizedBox(height: 16),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopToggle() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isTodayView = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isTodayView ? const Color(0xFF2E7BC4) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Hôm nay',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isTodayView ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isTodayView = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_isTodayView ? const Color(0xFF2E7BC4) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tuần này',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: !_isTodayView ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            '18',
            style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
          ),
          Text(
            'Thứ 5, Ngày 18/9/2025',
            style: TextStyle(fontSize: 16, color: Color(0xFF1E88E5)),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left),
              SizedBox(
                height: 60,
                width: MediaQuery.of(context).size.width - 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _weekDates.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedDateIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDateIndex = index),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2E7BC4) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _weekDates[index]['day']!,
                              style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _weekDates[index]['date']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Thứ 5, Ngày 18/9/2025',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}