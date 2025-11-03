import 'package:flutter/material.dart';

// 👇 THÊM CÁC IMPORT CẦN THIẾT
import 'package:btl_nhom2/api_service.dart';
import 'package:btl_nhom2/table/schedule_week_data.dart';
import 'package:btl_nhom2/table/teaching_schedule.dart';
import 'package:btl_nhom2/utils/schedule_utils.dart'; // <-- BỔ SUNG IMPORT
import '../widgets/schedule_card.dart'; // Giữ nguyên import của bạn

class ScheduleScreen extends StatefulWidget {
  // 👇 THÊM: Nhận userId
  final int userId;
  const ScheduleScreen({super.key, required this.userId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Quản lý State (Trạng thái)
  bool _isTodayView = false; // Bắt đầu với chế độ xem "Tuần này"
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
    // --- ⬇️ SỬA LỖI LOGIC 1: Gán Future và CHUỖI .then() ---
    _scheduleDataFuture = _apiService.fetchScheduleData(widget.userId, _weekOffset);
    // Tự động chọn ngày hôm nay KHI dữ liệu được tải xong LẦN ĐẦU
    _scheduleDataFuture.then((data) {
      if (mounted && _weekOffset == 0) {
        setState(() {
          _selectedDateIndex = data.weekData.todayIndex;
        });
      }
    });
    // --- ⬆️ KẾT THÚC SỬA LỖI 1 ---
  }

  // Hàm gọi API
  void _loadData() {
    // --- ⬇️ SỬA LỖI LOGIC 2: Gán Future MỚI và CHUỖI .then() ---
    var newFuture = _apiService.fetchScheduleData(widget.userId, _weekOffset);

    // Tự động chọn ngày (ngày đầu tuần, hoặc ngày hôm nay nếu về tuần hiện tại)
    newFuture.then((data) {
      if (mounted) {
        int newIndex = 0; // Mặc định là ngày đầu tuần
        if (_weekOffset == 0) {
          // Nếu quay về tuần hiện tại, chọn ngày hôm nay
          newIndex = data.weekData.todayIndex;
        }
        setState(() {
          _selectedDateIndex = newIndex;
        });
      }
    });

    // Cập nhật FutureBuilder
    setState(() {
      _scheduleDataFuture = newFuture;
    });
    // --- ⬆️ KẾT THÚC SỬA LỖI 2 ---
  }

  // <<< MỚI: Thêm hàm chuyển đổi Tiết -> Giờ (Giống HomeScreen) >>>
  String _convertLessonsToTime(String lessonString) {
    if (lessonString.isEmpty) return "N/A";
    List<int> lessons = [];
    try {
      if (lessonString.contains('-')) {
        final parts = lessonString.split('-');
        final int start = int.parse(parts[0].trim());
        final int end = int.parse(parts[1].trim());
        if (end < start) return lessonString;
        for (int i = start; i <= end; i++) {
          lessons.add(i);
        }
      } else {
        lessons.add(int.parse(lessonString.trim()));
      }
      if (lessons.isEmpty) return lessonString;

      // Gọi hàm từ ScheduleUtils
      return ScheduleUtils.getLessonTimeRange(lessons);
    } catch (e) {
      debugPrint('Lỗi phân tích chuỗi tiết học: $e');
      return lessonString; // Nếu lỗi, trả về chuỗi gốc
    }
  }

  // Hàm build giao diện chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ScheduleWeekData>(
        future: _scheduleDataFuture,
        builder: (context, snapshot) {
          // 1. TRẠNG THÁI ĐANG TẢI
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

          // Xác định danh sách lịch dạy cần hiển thị
          if (_isTodayView) {
            _currentSchedules = todayData.schedules;
          } else {
            // Kiểm tra an toàn trước khi truy cập index
            if (_selectedDateIndex >= 0 && _selectedDateIndex < weekData.dates.length) {
              final selectedDateKey = weekData.dates[_selectedDateIndex].fullDate;
              _currentSchedules = weekData.schedulesByDate[selectedDateKey] ?? [];
            } else {
              _currentSchedules = []; // Mặc định là rỗng nếu index sai
            }
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

                    // --- ⬇️ SỬA LỖI TIẾNG ANH TẠI ĐÂY ⬇️ ---
                    // 1. Lấy màu dựa trên trạng thái (tiếng Anh) từ DB
                    final color = _getStatusColor(schedule.status);
                    // 2. Lấy chữ (tiếng Việt) dựa trên trạng thái
                    final vietnameseStatus = _getVietnameseStatus(schedule.status);
                    // --- ⬆️ KẾT THÚC SỬA LỖI ⬆️ ---

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ScheduleCard(
                        time: _convertLessonsToTime(schedule.lessons),
                        lessons: 'Tiết ${schedule.lessons}',
                        title: schedule.title,
                        courseCode: schedule.courseCode,
                        location: schedule.location,

                        // Truyền trạng thái đã được dịch sang tiếng Việt
                        status: vietnameseStatus,

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

  // --- CÁC WIDGET HỖ TRỢ ĐÃ CẬP NHẬT ---

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
                    _loadData(); // Tải lại dữ liệu cho tuần trước
                  });
                },
              ),

              // (Giữ nguyên code của bạn, đã chuẩn)
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekData.dates.length, // 👈 Dùng list từ API
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                date.dayName, // Dữ liệu động
                                style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.dayNumber, // Dữ liệu động
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

              // Nút Tiến Tuần
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _weekOffset++; // Tăng offset
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
            // Kiểm tra an toàn trước khi truy cập index
            (_selectedDateIndex >= 0 && _selectedDateIndex < weekData.dates.length)
                ? weekData.dates[_selectedDateIndex].fullDateString // Dữ liệu động
                : "Vui lòng chọn ngày",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  // --- ⬇️ HÀM MỚI ĐỂ DỊCH SANG TIẾNG VIỆT ⬇️ ---
  String _getVietnameseStatus(String status) {
    switch (status) {
      case 'scheduled':
        return 'Đã lên lịch';
      case 'taught':
        return 'Đã dạy';
      case 'cancelled':
        return 'Đã hủy';
      case 'makeup': // <<< SỬA: THÊM TRẠNG THÁI DẠY BÙ
        return 'Dạy bù';
      case 'Đang diễn ra': // Giữ lại các trạng thái cũ phòng trường hợp API trả về
        return 'Đang diễn ra';
      case 'Sắp diễn ra':
        return 'Sắp diễn ra';
      case 'Đã kết thúc':
        return 'Đã kết thúc';
      default:
        return status; // Trả về nguyên bản nếu không nhận dạng được
    }
  }

  // Hàm hỗ trợ lấy màu (sao chép từ HomeScreen)
  Color _getStatusColor(String status) {
    // Hàm này VẪN DÙNG TIẾNG ANH (vì nó đọc dữ liệu gốc từ DB)
    if (status == 'Đang diễn ra') return Colors.green;
    if (status == 'Sắp diễn ra') return Colors.orange;
    if (status == 'Đã kết thúc') return Colors.grey;

    // Thêm các trạng thái từ DB của bạn
    if (status == 'scheduled') return Colors.blue;
    if (status == 'taught') return Colors.green;
    if (status == 'cancelled') return Colors.red;
    if (status == 'makeup') return Colors.blue; // <<< SỬA: THÊM MÀU CHO DẠY BÙ

    return Colors.blue; // Màu mặc định
  }
}