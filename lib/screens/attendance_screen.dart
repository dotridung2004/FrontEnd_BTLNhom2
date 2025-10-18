import 'package:flutter/material.dart';
import '../models/student.dart';
import '../generated/l10n.dart'; // Import tệp ngôn ngữ

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedClass;
  DateTime _selectedDate = DateTime(2025, 9, 19);
  bool _studentListLoaded = false;
  List<Student> _students = [];
  bool _isAttendanceSaved = false;

  // BỘ NHỚ ĐỆM MỚI: Lưu trữ danh sách điểm danh và trạng thái đã lưu cho mỗi lớp
  final Map<String, List<Student>> _attendanceCache = {};
  final Map<String, bool> _savedStatusCache = {};

  // Dữ liệu demo cho danh sách lớp
  final List<String> _classes = [
    'Phát triển ứng dụng cho các thiết bị di động-1-25 (CSE441_002)',
    'Phát triển ứng dụng cho các thiết bị di động-1-25 (CSE441_003)',
    'Cấu trúc dữ liệu và giải thuật (CSE221_001)'
  ];

  @override
  void initState() {
    super.initState();
    _selectedClass = _classes.first;
  }

  // Hàm tải danh sách sinh viên
  void _loadStudentList() {
    setState(() {
      _studentListLoaded = true;
      _isAttendanceSaved = false; // Reset trạng thái khi tải danh sách mới
      _students = [
        Student(id: '2251172211', name: 'Nguyễn Văn A', status: AttendanceStatus.none),
        Student(id: '2251172212', name: 'Trần Văn B', status: AttendanceStatus.none),
        Student(id: '2251172213', name: 'Nguyễn Minh C', status: AttendanceStatus.none),
      ];
      // Lưu danh sách vừa tải vào bộ nhớ đệm
      if (_selectedClass != null) {
        _attendanceCache[_selectedClass!] = _students;
        _savedStatusCache[_selectedClass!] = false;
      }
    });
    _showSuccessDialog("Tải danh sách sinh viên thành công");
  }

  // Hàm lưu điểm danh
  void _saveAttendance() {
    setState(() {
      _isAttendanceSaved = true; // Đánh dấu là đã lưu
      // Cập nhật trạng thái đã lưu vào bộ nhớ đệm
      if (_selectedClass != null) {
        _savedStatusCache[_selectedClass!] = true;
      }
    });
    _showSuccessDialog("Lưu điểm danh thành công");
  }

  // Hàm hiển thị dialog thông báo thành công
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Thông báo!"),
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

  // Hàm cập nhật trạng thái điểm danh của sinh viên
  void _updateAttendance(int index, AttendanceStatus status) {
    setState(() {
      // Nếu trạng thái điểm danh thay đổi, cho phép lưu lại
      if (_students[index].status != status) {
        _isAttendanceSaved = false;
        if (_selectedClass != null) {
          _savedStatusCache[_selectedClass!] = false;
        }
      }
      _students[index].status = status;
    });
  }

  // Các hàm đếm số lượng sinh viên theo trạng thái
  int get _presentCount => _students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount => _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get _lateCount => _students.where((s) => s.status == AttendanceStatus.late).length;

  @override
  Widget build(BuildContext context) {
    // Lấy các chuỗi văn bản đã được dịch
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildClassSelector(),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadStudentList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7BC4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  // Sử dụng chuỗi đã dịch
                    "Tải danh sách sinh viên",
                    style: const TextStyle(color: Colors.white, fontSize: 16)
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_studentListLoaded) ...[
              _buildSummaryCards(localizations),
              const SizedBox(height: 16),
              _buildStudentListView(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Vô hiệu hóa nút nếu đã lưu, cho phép nhấn khi chưa lưu
                  onPressed: _isAttendanceSaved ? null : _saveAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7BC4),
                    // Làm mờ nút khi bị vô hiệu hóa
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    // Thay đổi văn bản trên nút tùy theo trạng thái
                      _isAttendanceSaved ? localizations.attendanceSaved : "Lưu điểm danh",
                      style: const TextStyle(color: Colors.white, fontSize: 16)
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text("Chọn lớp"),
          value: _selectedClass,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7BC4)),
          onChanged: (String? newValue) {
            setState(() {
              _selectedClass = newValue;
              // KIỂM TRA BỘ NHỚ ĐỆM KHI CHUYỂN LỚP
              if (newValue != null && _attendanceCache.containsKey(newValue)) {
                // Nếu lớp đã có trong cache, tải lại dữ liệu từ cache
                _students = _attendanceCache[newValue]!;
                _isAttendanceSaved = _savedStatusCache[newValue]!;
                _studentListLoaded = true;
              } else {
                // Nếu lớp chưa có, reset lại
                _studentListLoaded = false;
                _isAttendanceSaved = false;
                _students.clear();
              }
            });
          },
          items: _classes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
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
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF2E7BC4)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard("Có mặt", _presentCount.toString(), Colors.green),
        _summaryCard("Vắng", _absentCount.toString(), Colors.red),
        _summaryCard("Muộn", _lateCount.toString(), Colors.orange),
      ],
    );
  }

  Widget _summaryCard(String title, String count, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 16,
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

  Widget _buildStudentListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _students.length,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(student.id, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Row(
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
}

