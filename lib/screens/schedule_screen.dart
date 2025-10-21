import 'package:flutter/material.dart';

// 👇 THÊM CÁC IMPORT CẦN THIẾT
import 'package:btl_nhom2/api_service.dart';
import 'package:btl_nhom2/table/schedule_week_data.dart';
import 'package:btl_nhom2/table/teaching_schedule.dart';
import '../widgets/schedule_card.dart'; // Giữ nguyên import của bạn

class ScheduleScreen extends StatefulWidget {
  // 👇 THÊM: Nhận userId
  final int userId;
  const ScheduleScreen({super.key, required this.userId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Quản lý State
  bool _isTodayView = false; // Bắt đầu với view Tuần này
  int _selectedDateIndex = 0; // Index của ngày được chọn trong tuần
  int _weekOffset = 0; // 0 = tuần này, -1 = tuần trước, 1 = tuần sau

  // Quản lý API
  final ApiService _apiService = ApiService();
  late Future<ScheduleWeekData> _scheduleDataFuture;

  // Danh sách lịch dạy sẽ được hiển thị (được cập nhật)
  List<TeachingSchedule> _currentSchedules = [];

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu lần đầu
    _loadData();
  }

  // Hàm gọi API
  void _loadData() {
    _scheduleDataFuture = _apiService.fetchScheduleData(widget.userId, _weekOffset);
  }

  // Hàm build giao diện chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ScheduleWeekData>(
        future: _scheduleDataFuture,
        builder: (context, snapshot) {
          // 1. TRẠNG THÁI LOADING
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

          // ✅ Lấy dữ liệu thành công
          final scheduleData = snapshot.data!;
          final todayData = scheduleData.todayData;
          final weekData = scheduleData.weekData;

          // Cập nhật index ngày được chọn nếu là tuần hiện tại
          if (_weekOffset == 0) {
            _selectedDateIndex = weekData.todayIndex;
          }

          // Xác định danh sách lịch dạy cần hiển thị
          if (_isTodayView) {
            _currentSchedules = todayData.schedules;
          } else {
            // Lấy ngày được chọn từ list `dates`
            final selectedDateKey = weekData.dates[_selectedDateIndex].fullDate;
            // Lấy lịch từ map `schedulesByDate`
            _currentSchedules = weekData.schedulesByDate[selectedDateKey] ?? [];
          }

          // Trả về giao diện chính
          return Column(
            children: [
              _buildTopToggle(),
              _isTodayView
                  ? _buildTodayView(todayData) // 👈 Dùng data
                  : _buildWeekView(weekData), // 👈 Dùng data

              // DANH SÁCH LỊCH DẠY ĐỘNG
              Expanded(
                child: _currentSchedules.isEmpty
                    ? const Center(
                  child: Text(
                    '🎉 Không có lịch dạy cho ngày này.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _currentSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _currentSchedules[index];
                    final color = _getStatusColor(schedule.status);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ScheduleCard(
                        time: schedule.time,
                        lessons: schedule.lessons,
                        title: schedule.title,
                        courseCode: schedule.courseCode,
                        location: schedule.location,
                        status: schedule.status,
                        statusColor: color,
                        borderColor: color,
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // --- CÁC WIDGET HELPER ĐÃ CẬP NHẬT ---

  // (Hàm này giữ nguyên như cũ)
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

  // Sửa lại để nhận data động
  Widget _buildTodayView(ScheduleToday todayData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            todayData.dayNumber, // 👈 Dữ liệu động
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
          ),
          Text(
            todayData.fullDateString, // 👈 Dữ liệu động
            style: const TextStyle(fontSize: 16, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

// Sửa lại để nhận data động và xử lý chuyển tuần
  Widget _buildWeekView(ScheduleWeek weekData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút Lùi Tuần
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _weekOffset--; // Giảm offset
                    _selectedDateIndex = 0; // Chọn ngày đầu tuần mới
                    _loadData(); // Tải lại dữ liệu cho tuần trước
                  });
                },
              ),

              // --- ⬇️ SỬA LỖI OVERFLOW TẠI ĐÂY ⬇️ ---
              // 1. Thay thế SizedBox bằng Expanded
              Expanded(
                child: SizedBox(
                  height: 60,
                  // 2. Bỏ 'width' cố định đi
                  // width: MediaQuery.of(context).size.width - 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekData.dates.length, // 👈 Dùng list từ API
                    // 3. (QUAN TRỌNG) Thêm 2 dòng này để căn giữa
                    // nếu không đủ 7 ngày (ví dụ chỉ có 5)
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Bỏ padding mặc định của ListView
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final date = weekData.dates[index];
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
                                date.dayName, // 👈 Dữ liệu động
                                style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.dayNumber, // 👈 Dữ liệu động
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
              ),
              // --- ⬆️ KẾT THÚC SỬA LỖI ⬆️ ---

              // Nút Tiến Tuần
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _weekOffset++; // Tăng offset
                    _selectedDateIndex = 0; // Chọn ngày đầu tuần mới
                    _loadData(); // Tải lại dữ liệu cho tuần sau
                  });
                },
              ),
            ],
          ),
        ),
        // Hiển thị ngày đang chọn
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            weekData.dates[_selectedDateIndex].fullDateString, // 👈 Dữ liệu động
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  // Helper lấy màu (copy từ HomeScreen)
  Color _getStatusColor(String status) {
    if (status == 'Đang diễn ra') return Colors.green;
    if (status == 'Sắp diễn ra') return Colors.orange;
    if (status == 'Đã kết thúc') return Colors.grey;
    // Thêm các status từ DB của bạn
    if (status == 'scheduled') return Colors.blue;
    if (status == 'taught') return Colors.green;
    if (status == 'cancelled') return Colors.red;
    return Colors.blue;
  }
}