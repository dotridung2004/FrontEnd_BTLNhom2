import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Dùng để format ngày

// 👇 Import các model và service cần thiết
import '../models/student.dart';
import '../table/schedule_dropdown_item.dart';
import '../api_service.dart';

class AttendanceScreen extends StatefulWidget {
  // 👇 THÊM: Nhận userId từ HomeScreen
  final int userId;
  const AttendanceScreen({super.key, required this.userId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // --- Biến Quản lý Trạng thái ---
  int? _selectedScheduleId; // Lưu ID lịch dạy thay vì String
  DateTime _selectedDate = DateTime.now(); // Mặc định là hôm nay
  bool _studentListLoaded = false; // Đã tải xong danh sách SV hay chưa

  // --- Danh sách Dữ liệu ---
  List<ScheduleDropdownItem> _scheduleOptions = []; // Dữ liệu cho dropdown lớp học
  List<Student> _students = []; // Danh sách sinh viên và trạng thái điểm danh

  // --- Trạng thái Loading ---
  bool _isLoadingSchedules = true; // Bắt đầu tải danh sách lớp ngay khi mở màn hình
  bool _isLoadingStudents = false; // Đang tải danh sách sinh viên
  bool _isSaving = false; // Đang lưu điểm danh

  // --- Service Gọi API ---
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Tải danh sách lịch dạy cho ngày hôm nay khi màn hình được khởi tạo
    _fetchSchedulesForDate(_selectedDate);
  }

  // --- Các Hàm Gọi API ---

  // Lấy danh sách lịch dạy (cho dropdown) dựa vào ngày đã chọn
  Future<void> _fetchSchedulesForDate(DateTime date) async {
    setState(() {
      _isLoadingSchedules = true; // Bắt đầu loading
      _scheduleOptions = []; // Xóa danh sách cũ
      _selectedScheduleId = null; // Reset lựa chọn lớp
      _studentListLoaded = false; // Ẩn danh sách sinh viên
      _students = []; // Xóa danh sách sinh viên cũ
    });
    try {
      // Gọi API
      final schedules = await _apiService.fetchSchedulesByDate(widget.userId, date);
      // Cập nhật UI nếu widget còn tồn tại
      if (mounted) {
        setState(() {
          _scheduleOptions = schedules;
          // Tự động chọn lớp đầu tiên nếu có
          if (_scheduleOptions.isNotEmpty) {
            _selectedScheduleId = _scheduleOptions.first.scheduleId;
          }
        });
      }
    } catch (e) {
      // Hiển thị lỗi nếu có
      if (mounted) _showErrorDialog("Lỗi tải danh sách lớp: ${e.toString()}");
    } finally {
      // Kết thúc loading dù thành công hay thất bại
      if (mounted) setState(() => _isLoadingSchedules = false);
    }
  }

  // Tải danh sách sinh viên cho lớp và ngày đã chọn
  Future<void> _loadStudentList() async {
    // Kiểm tra xem đã chọn lớp chưa
    if (_selectedScheduleId == null) {
      _showErrorDialog("Vui lòng chọn một lớp học.");
      return;
    }
    setState(() {
      _isLoadingStudents = true; // Bắt đầu loading
      _studentListLoaded = false; // Ẩn danh sách cũ (nếu có)
      _students = []; // Xóa danh sách cũ
    });
    try {
      // Gọi API
      final students = await _apiService.fetchStudentsForSchedule(_selectedScheduleId!, _selectedDate);
      if (mounted) {
        setState(() {
          _students = students;
          _studentListLoaded = true; // Đánh dấu đã tải xong để hiển thị danh sách
        });
        _showSuccessDialog("Tải danh sách sinh viên thành công");
      }
    } catch (e) {
      if (mounted) _showErrorDialog("Lỗi tải danh sách sinh viên: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoadingStudents = false); // Kết thúc loading
    }
  }

  // Lưu trạng thái điểm danh hiện tại lên server
  Future<void> _saveAttendance() async {
    // Kiểm tra xem có dữ liệu để lưu không
    if (_selectedScheduleId == null || _students.isEmpty) {
      _showErrorDialog("Chưa có dữ liệu điểm danh để lưu.");
      return;
    }
    setState(() => _isSaving = true); // Bắt đầu loading
    try {
      // Gọi API lưu hàng loạt
      await _apiService.saveAttendanceBulk(_selectedScheduleId!, _selectedDate, _students);
      if (mounted) _showSuccessDialog("Lưu điểm danh thành công!");
    } catch (e) {
      if (mounted) _showErrorDialog("Lỗi khi lưu điểm danh: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSaving = false); // Kết thúc loading
    }
  }

  // --- Các Hàm Cập nhật UI ---

  // Cập nhật trạng thái điểm danh của sinh viên trong danh sách `_students`
  void _updateAttendance(int index, AttendanceStatus status) {
    // Chỉ cập nhật state, không gọi API ở đây
    setState(() {
      _students[index].status = status;
    });
  }

  // --- Các Dialog Thông báo ---

  void _showSuccessDialog(String message) {
    if (!mounted) return; // Kiểm tra widget còn tồn tại không
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text("Thông báo!")]),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    // Làm sạch thông báo lỗi
    final displayMessage = message
        .replaceFirst('Exception: ', '')
        .replaceAll('❌ ', '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text("Lỗi!")]),
        content: Text(displayMessage),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Đóng", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- Getters tính toán số lượng điểm danh ---
  int get _presentCount => _students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount => _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get _lateCount => _students.where((s) => s.status == AttendanceStatus.late).length;

  // --- Hàm Build Chính ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Dùng RefreshIndicator để cho phép kéo xuống tải lại danh sách lớp
      body: RefreshIndicator(
        onRefresh: () => _fetchSchedulesForDate(_selectedDate),
        child: SingleChildScrollView( // Cho phép cuộn nếu nội dung dài
          physics: const AlwaysScrollableScrollPhysics(), // Luôn cho phép cuộn (để RefreshIndicator hoạt động)
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildClassSelector(), // Dropdown chọn lớp
              const SizedBox(height: 16),
              _buildDateSelector(), // Chọn ngày
              const SizedBox(height: 16),
              // Nút tải danh sách sinh viên
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Vô hiệu hóa nút nếu chưa chọn lớp hoặc đang tải SV
                  onPressed: _selectedScheduleId == null || _isLoadingStudents ? null : _loadStudentList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7BC4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey.shade400, // Màu khi bị vô hiệu hóa
                  ),
                  child: _isLoadingStudents
                  // Hiển thị vòng xoay nếu đang tải
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  // Hiển thị text nếu không tải
                      : const Text("Tải danh sách sinh viên", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),

              // --- Vùng hiển thị động ---
              // Chỉ hiển thị khi đã tải xong danh sách SV (_studentListLoaded = true)
              if (_studentListLoaded) ...[
                _buildSummaryCards(), // Các thẻ tóm tắt (Có mặt, Vắng, Muộn)
                const SizedBox(height: 16),
                _buildStudentListView(), // Danh sách sinh viên
                const SizedBox(height: 24),
                // Nút lưu điểm danh
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAttendance, // Vô hiệu hóa nếu đang lưu
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7BC4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isSaving // Hiển thị vòng xoay nếu đang lưu
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Lưu điểm danh", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ]
              // Hiển thị thông báo nếu tải xong danh sách lớp nhưng không có lớp nào
              else if (!_isLoadingSchedules && _scheduleOptions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    'Không có lịch dạy nào cho ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              // Hiển thị vòng xoay nếu đang tải danh sách lớp ban đầu
              else if (_isLoadingSchedules)
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Các Widget con (Builders) ---

  // Dropdown chọn lớp học
  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        // Dùng DropdownButton<int> vì giá trị là scheduleId (số nguyên)
        child: DropdownButton<int>(
          value: _selectedScheduleId, // Giá trị đang được chọn
          isExpanded: true, // Mở rộng hết chiều ngang
          // Hiển thị gợi ý dựa trên trạng thái loading
          hint: _isLoadingSchedules
              ? const Row(children: [SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text("Đang tải lớp học...")])
              : const Text("Chọn lớp học"),
          // Icon bên phải dropdown
          icon: _isLoadingSchedules
              ? const SizedBox.shrink() // Ẩn icon khi đang tải
              : const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7BC4)),
          // Hàm được gọi khi chọn item mới (chỉ cho phép chọn khi không loading)
          onChanged: _isLoadingSchedules ? null : (int? newValue) {
            if (newValue != null && newValue != _selectedScheduleId) {
              setState(() {
                _selectedScheduleId = newValue; // Cập nhật ID lớp đã chọn
                _studentListLoaded = false; // Reset danh sách sinh viên
                _students.clear();
              });
            }
          },
          // Tạo các mục DropdownMenuItem từ danh sách _scheduleOptions
          items: _scheduleOptions.map<DropdownMenuItem<int>>((ScheduleDropdownItem item) {
            return DropdownMenuItem<int>(
              value: item.scheduleId, // Giá trị là ID
              child: Text(
                item.displayName, // Hiển thị tên lớp + môn + tiết
                overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                style: TextStyle(
                  // Đổi màu nếu là item đang được chọn (tùy chọn)
                  color: _selectedScheduleId == item.scheduleId ? Colors.blue.shade800 : Colors.black87,
                  fontWeight: _selectedScheduleId == item.scheduleId ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          // Text hiển thị khi dropdown bị vô hiệu hóa (disable)
          disabledHint: _isLoadingSchedules
              ? const Text("Đang tải...")
              : const Text("Không có lớp nào", style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  // Widget chọn ngày
  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020), // Giới hạn ngày bắt đầu
          lastDate: DateTime(2030), // Giới hạn ngày kết thúc
          locale: const Locale('vi', 'VN'), // Hiển thị tiếng Việt
        );
        // Nếu người dùng chọn ngày mới
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked; // Cập nhật ngày đã chọn
            // Tải lại danh sách lịch dạy cho ngày mới này
            _fetchSchedulesForDate(picked);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate), // Format ngày dd/MM/yyyy
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF2E7BC4)),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị các thẻ tóm tắt (giữ nguyên)
  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard("Có mặt", _presentCount.toString(), Colors.green),
        _summaryCard("Vắng", _absentCount.toString(), Colors.red),
        _summaryCard("Muộn", _lateCount.toString(), Colors.orange),
      ],
    );
  }
  // Widget con cho thẻ tóm tắt (giữ nguyên)
  Widget _summaryCard(String title, String count, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 16, // Điều chỉnh lại chiều rộng một chút
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 5, backgroundColor: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách sinh viên
  Widget _buildStudentListView() {
    // Quan trọng: Phải đặt trong widget cha có giới hạn chiều cao
    // hoặc dùng shrinkWrap + NeverScrollableScrollPhysics nếu đặt trong SingleChildScrollView
    return ListView.builder(
      shrinkWrap: true, // Co lại theo nội dung
      physics: const NeverScrollableScrollPhysics(), // Không cho phép ListView tự cuộn
      itemCount: _students.length, // Số lượng sinh viên
      itemBuilder: (context, index) {
        final student = _students[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: Colors.grey.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thông tin sinh viên (Tên + ID) - dùng Flexible để tránh tràn nếu tên quá dài
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                      Text(student.studentId, style: TextStyle(color: Colors.grey[600])), // Dùng studentId
                    ],
                  ),
                ),
                // Các nút điểm danh
                Row(
                  mainAxisSize: MainAxisSize.min, // Giúp Row không chiếm hết không gian còn lại
                  children: [
                    _attendanceButton(
                      icon: Icons.check,
                      color: Colors.green,
                      isSelected: student.status == AttendanceStatus.present,
                      onTap: () => _updateAttendance(index, AttendanceStatus.present),
                    ),
                    const SizedBox(width: 8),
                    _attendanceButton(
                      icon: Icons.close,
                      color: Colors.red,
                      isSelected: student.status == AttendanceStatus.absent,
                      onTap: () => _updateAttendance(index, AttendanceStatus.absent),
                    ),
                    const SizedBox(width: 8),
                    _attendanceButton(
                      icon: Icons.access_time_filled,
                      color: Colors.orange,
                      isSelected: student.status == AttendanceStatus.late,
                      onTap: () => _updateAttendance(index, AttendanceStatus.late),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget con cho nút điểm danh (giữ nguyên)
  Widget _attendanceButton({required IconData icon, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isSelected ? color : Colors.grey[200],
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
      ),
    );
  }
} // Kết thúc class _AttendanceScreenState