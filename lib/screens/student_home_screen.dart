// lib/screens/student_home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // 👈 *** THÊM IMPORT NÀY ***

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
      // Container(child: Center(child: Text('Lịch học (Sinh viên)'))),
      // Container(child: Center(child: Text('Kết quả (Sinh viên)'))),
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
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
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
            child: const Text('TLU',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.calendar_today), label: 'Lịch học'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.bar_chart), label: 'Kết quả'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Tài khoản'), // 👈 THÊM NÚT NÀY
        ],
      ),
    );
  }
}

// --- vvv THAY ĐỔI LỚN BẮT ĐẦU TỪ ĐÂY vvv ---

// --- Nội dung trang chủ của Sinh viên ---
class StudentHomeScreenContent extends StatefulWidget {
  final int userId;
  const StudentHomeScreenContent({super.key, required this.userId});

  @override
  State<StudentHomeScreenContent> createState() =>
      _StudentHomeScreenContentState();
}

class _StudentHomeScreenContentState extends State<StudentHomeScreenContent> {
  final ApiService _apiService = ApiService();

  // --- 👇 QUẢN LÝ 2 FUTURES KHÁC NHAU ---
  late Future<StudentHomeSummary> _summaryFuture;
  late Future<List<StudentScheduleItem>> _weeklyScheduleFuture;
  // --- 👆 ---

  // State cho SegmentedButton: {0} = Hôm nay, {1} = Tuần này
  Set<int> _selectedView = {0};

  // --- 👇 STATE CHO CHẾ ĐỘ XEM TUẦN ---
  List<DateTime> _weekDays = [];
  DateTime _selectedDateOnScroller = DateTime.now();
  final ScrollController _dateScrollController = ScrollController();
  final ScrollController _weekListScrollController = ScrollController();

  // Map để lưu GlobalKey cho mỗi ngày -> dùng để cuộn tới
  final Map<String, GlobalKey> _dateKeys = {};
  // --- 👆 ---

  @override
  void initState() {
    super.initState();
    // Khởi tạo cả hai future
    _summaryFuture = _apiService.fetchStudentHomeSummary(widget.userId);
    _weeklyScheduleFuture =
        _apiService.fetchStudentWeeklySchedule(widget.userId);

    // Tạo danh sách 7 ngày trong tuần
    _weekDays = _generateWeekDays(DateTime.now());

    // Đặt ngày được chọn trên scroller là hôm nay
    _selectedDateOnScroller = _weekDays.firstWhere(
            (day) => isSameDay(day, DateTime.now()),
        orElse: () => _weekDays[0]);

    // Cuộn thanh trượt ngày đến hôm nay (nếu có thể)
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelectedDateScroller());
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    _weekListScrollController.dispose();
    super.dispose();
  }

  // --- 👇 CÁC HÀM HELPER CHO VIỆC TÍNH TOÁN NGÀY THÁNG ---

  // Tạo danh sách 7 ngày (T2-CN) cho tuần hiện tại
  List<DateTime> _generateWeekDays(DateTime referenceDate) {
    // 1 = Thứ 2, 7 = Chủ Nhật
    DateTime startOfWeek =
    referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Format ngày cho header (ví dụ: "Thứ 2, Ngày 15/9/2025")
  String _formatDateHeader(DateTime date) {
    return DateFormat('EEEE, \'Ngày\' dd/MM/yyyy', 'vi_VN').format(date);
  }

  // Cuộn thanh trượt ngang (date scroller) đến ngày đã chọn
  void _scrollToSelectedDateScroller() {
    final selectedIndex =
    _weekDays.indexWhere((day) => isSameDay(day, _selectedDateOnScroller));
    if (selectedIndex != -1 && _dateScrollController.hasClients) {
      // (60 width + 8 padding) * index
      final offset =
          (selectedIndex * 68.0) - (MediaQuery.of(context).size.width / 2) + 34;
      _dateScrollController.animateTo(
        offset < 0 ? 0 : offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Cuộn danh sách lịch học (list view) đến ngày tương ứng
  void _scrollToScheduleDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final key = _dateKeys[dateKey];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0, // Cuộn lên đầu
      );
    }
  }

  // --- 👆 HẾT HÀM HELPER ---

  @override
  Widget build(BuildContext context) {
    // Bây giờ root là Column, không phải FutureBuilder
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề "Teaching Schedule"
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Teaching Schedule',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Nút chuyển "Hôm nay" / "Tuần này"
        Center(
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('Hôm nay'),
                ),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('Tuần này'),
                ),
              ),
            ],
            selected: _selectedView,
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _selectedView = newSelection;
              });
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              selectedBackgroundColor: Colors.blue.shade800,
              selectedForegroundColor: Colors.white,
              foregroundColor: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3. Hiển thị nội dung dựa trên tab đã chọn
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedView.first == 0
                ? _buildTodayView()
                : _buildThisWeekView(),
          ),
        ),
      ],
    );
  }

  // --- WIDGET CHO TAB "HÔM NAY" ---
  Widget _buildTodayView() {
    return FutureBuilder<StudentHomeSummary>(
      key: const ValueKey('today'), // Key cho AnimatedSwitcher
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Lỗi tải dữ liệu: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Không có dữ liệu.'));
        }

        final homeData = snapshot.data!;
        final schedules = homeData.schedules; // Lịch học hôm nay

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            _buildTodayDateCard(), // Thẻ ngày tháng
            const SizedBox(height: 24),

            if (schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                    child: Text('🎉 Bạn không có lịch học hôm nay.',
                        style: TextStyle(fontSize: 16, color: Colors.grey))),
              ),

            // Danh sách lịch học
            ...schedules.map((schedule) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildStudentScheduleCard(schedule),
            )),
          ],
        );
      },
    );
  }

  // --- WIDGET CHO TAB "TUẦN NÀY" (Logic mới) ---
  Widget _buildThisWeekView() {
    return FutureBuilder<List<StudentScheduleItem>>(
      key: const ValueKey('week'), // Key cho AnimatedSwitcher
      future: _weeklyScheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Lỗi tải lịch tuần: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Hiển thị thanh trượt ngày ngay cả khi không có lịch
          return Column(
            children: [
              _buildDateScroller(),
              const Expanded(
                child: Center(
                    child: Text('Không có lịch học cho tuần này.',
                        style: TextStyle(fontSize: 16, color: Colors.grey))),
              ),
            ],
          );
        }

        final allSchedules = snapshot.data!;

        // --- 👇 GROUP LỊCH HỌC THEO NGÀY ---
        // 1. Gán GlobalKey cho mỗi ngày có lịch học
        _dateKeys.clear();
        for (var schedule in allSchedules) {
          final dateKey = DateFormat('yyyy-MM-dd').format(schedule.scheduleDate);
          if (!_dateKeys.containsKey(dateKey)) {
            _dateKeys[dateKey] = GlobalKey();
          }
        }

        // 2. Group các buổi học theo ngày (dùng 'package:collection')
        final groupedSchedules = groupBy(
          allSchedules,
          // Group bằng String 'yyyy-MM-dd' để key đơn giản hơn
              (item) => DateFormat('yyyy-MM-dd').format(item.scheduleDate),
        );
        // --- 👆 KẾT THÚC GROUPING ---

        return Column(
          children: [
            _buildDateScroller(), // Thanh trượt ngang chọn ngày
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: _weekListScrollController, // Controller cho danh sách
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: groupedSchedules.keys.length, // Số lượng ngày có lịch
                itemBuilder: (context, index) {
                  final dateString = groupedSchedules.keys.elementAt(index);
                  final schedulesForDay = groupedSchedules[dateString]!;
                  final date = DateFormat('yyyy-MM-dd').parse(dateString);

                  // Lấy GlobalKey cho ngày này
                  final key = _dateKeys[dateString];

                  return Column(
                    key: key, // Gán Key vào đây
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (ví dụ: "Thứ 2, Ngày 15/9/2025")
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                        child: Text(
                          _formatDateHeader(date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      // Danh sách lịch học cho ngày đó
                      ...schedulesForDay.map((schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildStudentScheduleCard(schedule),
                      )),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET THANH TRƯỢT NGÀY (Mới) ---
  Widget _buildDateScroller() {
    return Container(
      height: 60, // Chiều cao cố định
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final date = _weekDays[index];
          final isSelected = isSameDay(date, _selectedDateOnScroller);

          // "T2", "T3", ... "CN"
          String dayOfWeek = DateFormat('E', 'vi_VN').format(date).toUpperCase();
          if (dayOfWeek.startsWith('T')) {
            dayOfWeek = 'T${date.weekday + 1}'; // T2, T3, ... T7
          } else if (dayOfWeek.startsWith('C')) {
            dayOfWeek = 'CN';
          }

          final String dayOfMonth = DateFormat('d').format(date); // "15", "16"

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateOnScroller = date;
              });
              // Cuộn thanh ngang
              _scrollToSelectedDateScroller();
              // Cuộn danh sách dọc
              _scrollToScheduleDate(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayOfWeek,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayOfMonth,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET THẺ NGÀY (Cho tab "Hôm nay") ---
  Widget _buildTodayDateCard() {
    final now = DateTime.now();
    final day = DateFormat('d').format(now);
    final dayOfWeekAndDate =
    DateFormat('EEEE, \'Ngày\' dd/MM/yyyy', 'vi_VN').format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayOfWeekAndDate,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET THẺ LỊCH HỌC (Dùng chung cho cả 2 tab) ---
  Color _getStatusColor(String status) {
    if (status == 'Đang diễn ra') return Colors.green;
    if (status == 'Sắp diễn ra') return Colors.orange;
    // Màu mặc định cho viền (giống trong hình 'Tuần này')
    return Colors.orange.shade700; // ✅ *** ĐÃ SỬA LỖI TẠI ĐÂY ***
  }

  Widget _buildStudentScheduleCard(StudentScheduleItem schedule) {
    // Màu viền cam/đỏ như trong hình
    final statusColor = _getStatusColor(schedule.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 6)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3))
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
                  Text(
                    schedule.timeRange,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  Text(schedule.lessons,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: schedule.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                TextSpan(
                  text: ' (${schedule.courseCode})',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: Colors.blue.shade800, size: 20),
                      const SizedBox(width: 8),
                      Text(schedule.teacherName,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.blue.shade800, size: 20),
                      const SizedBox(width: 8),
                      Text(schedule.location,
                          style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Xử lý khi nhấn nút Tài liệu
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  elevation: 0,
                ),
                child: const Text('Tài liệu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}