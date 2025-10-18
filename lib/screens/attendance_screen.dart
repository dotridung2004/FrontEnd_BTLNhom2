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

  final Map<String, List<Student>> _attendanceCache = {};
  final Map<String, bool> _savedStatusCache = {};

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

  String _getCacheKey() {
    if (_selectedClass == null) return '';
    String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    return '$_selectedClass-$formattedDate';
  }

  void _loadStudentList() {
    final key = _getCacheKey();
    if (key.isEmpty) return;
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _studentListLoaded = true;
      _isAttendanceSaved = false;
      _students = [
        Student(id: '2251172211', name: 'Nguyễn Văn A', status: AttendanceStatus.none),
        Student(id: '2251172212', name: 'Trần Văn B', status: AttendanceStatus.none),
        Student(id: '2251172213', name: 'Nguyễn Minh C', status: AttendanceStatus.none),
      ];
      _attendanceCache[key] = List.from(_students);
      _savedStatusCache[key] = false;
    });
    _showCustomDialog(
        title: localizations.logoutDialogTitle,
        message: "Tải danh sách sinh viên thành công");
  }

  void _saveAttendance() {
    final key = _getCacheKey();
    if (key.isEmpty) return;
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _isAttendanceSaved = true;
      _savedStatusCache[key] = true;
    });
    _showCustomDialog(
        title: localizations.logoutDialogTitle,
        message: "Lưu điểm danh thành công");
  }

  void _updateAttendance(int index, AttendanceStatus status) {
    final key = _getCacheKey();
    if (key.isEmpty) return;
    setState(() {
      if (_students[index].status != status) {
        _isAttendanceSaved = false;
        if (_savedStatusCache.containsKey(key)) {
          _savedStatusCache[key] = false;
        }
      }
      _students[index].status = status;
      _attendanceCache[key] = List.from(_students);
    });
  }

  // ✅ SỬA LỖI: Cập nhật lại giao diện Dialog
  void _showCustomDialog({required String title, required String message}) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black)),
                    const SizedBox(height: 16),
                    Text(message,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87)),
                    const SizedBox(height: 24),
                    Center( // Căn giữa nút bấm
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 50),
                        ),
                        child: Text(localizations.confirmButton,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int get _presentCount =>
      _students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount =>
      _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get _lateCount =>
      _students.where((s) => s.status == AttendanceStatus.late).length;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildClassSelector(localizations),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            if (!_studentListLoaded)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadStudentList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7BC4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(localizations.loadStudentList,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 16)),
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
                  onPressed: _isAttendanceSaved ? null : _saveAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7BC4),
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                      _isAttendanceSaved
                          ? localizations.attendanceSaved
                          : localizations.saveAttendance,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ... (Các hàm build còn lại không thay đổi)
  Widget _buildClassSelector(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(localizations.selectClass),
          value: _selectedClass,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7BC4)),
          onChanged: (String? newValue) {
            setState(() {
              _selectedClass = newValue;
              final key = _getCacheKey();

              if (_attendanceCache.containsKey(key)) {
                _students = List.from(_attendanceCache[key]!);
                _isAttendanceSaved = _savedStatusCache[key]!;
                _studentListLoaded = true;
              } else {
                _students.clear();
                _studentListLoaded = false;
                _isAttendanceSaved = false;
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
            final key = _getCacheKey();

            if (_attendanceCache.containsKey(key)) {
              _students = List.from(_attendanceCache[key]!);
              _isAttendanceSaved = _savedStatusCache[key]!;
              _studentListLoaded = true;
            } else {
              _students.clear();
              _studentListLoaded = false;
              _isAttendanceSaved = false;
            }
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
        _summaryCard(localizations.present, _presentCount.toString(), Colors.green),
        _summaryCard(localizations.absent, _absentCount.toString(), Colors.red),
        _summaryCard(localizations.late, _lateCount.toString(), Colors.orange),
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

