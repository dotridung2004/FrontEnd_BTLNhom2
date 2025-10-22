import 'package:flutter/material.dart';
import 'dart:io'; // Cần cho việc upload file (nếu có)
// import 'package:file_picker/file_picker.dart'; // Thêm package này vào pubspec.yaml nếu muốn upload file
import 'package:intl/intl.dart';

// Import các model và service cần thiết
import '../api_service.dart';
import '../models/leave_makeup_summary.dart';
import '../models/pending_makeup_item.dart';
import '../models/leave_history_item.dart';
import '../models/available_schedule.dart';


//==================================================================
// MÀN HÌNH 1: MÀN HÌNH NGHỈ/BÙ CHÍNH
//==================================================================
class LeaveAndMakeupScreen extends StatefulWidget {
  final int userId;
  const LeaveAndMakeupScreen({super.key, required this.userId});

  @override
  State<LeaveAndMakeupScreen> createState() => _LeaveAndMakeupScreenState();
}

class _LeaveAndMakeupScreenState extends State<LeaveAndMakeupScreen> {
  final ApiService _apiService = ApiService();

  // Dùng Future để quản lý các lệnh gọi API
  late Future<LeaveMakeupSummary> _summaryFuture;
  late Future<List<PendingMakeupItem>> _pendingMakeupFuture;
  late Future<List<LeaveHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadData(); // Tải tất cả dữ liệu khi màn hình khởi động
  }

  // Hàm tải lại toàn bộ dữ liệu (dùng cho pull-to-refresh)
  Future<void> _loadData() async {
    setState(() {
      _summaryFuture = _apiService.fetchLeaveMakeupSummary(widget.userId);
      _pendingMakeupFuture = _apiService.fetchPendingMakeupSchedules(widget.userId);
      _historyFuture = _apiService.fetchLeaveHistory(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // Dùng RefreshIndicator để cho phép kéo xuống tải lại
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Luôn cho phép cuộn
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummarySection(), // Phần tóm tắt
                const SizedBox(height: 20),
                _buildActionButtons(), // Các nút đăng ký
                const SizedBox(height: 20),
                _buildPendingMakeupSection(), // Danh sách cần bù
                const SizedBox(height: 12),
                _buildHistorySection(), // Lịch sử nghỉ
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget xây dựng phần tóm tắt động
  Widget _buildSummarySection() {
    return FutureBuilder<LeaveMakeupSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        // Trạng thái đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 62, child: Center(child: CircularProgressIndicator()));
        }
        // Trạng thái lỗi
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(16)),
            child: Text('Lỗi tải tóm tắt: ${snapshot.error}', style: TextStyle(color: Colors.red.shade900)),
          );
        }
        // Trạng thái thành công
        final summary = snapshot.data ?? LeaveMakeupSummary(leaveCount: 0, pendingMakeupCount: 0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Buổi đã nghỉ: ${summary.leaveCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Buổi cần bù: ${summary.pendingMakeupCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        );
      },
    );
  }

  // Các nút hành động
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              // Sau khi quay lại từ màn hình đăng ký, tải lại dữ liệu nếu có thay đổi
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterLeaveScreen(userId: widget.userId)),
              );
              if (result == true) _loadData(); // Nếu màn hình con trả về true
            },
            icon: const Icon(Icons.cancel_outlined, color: Colors.white, size: 28),
            label: const Text('Đăng ký nghỉ', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Nút này chỉ để thông báo, người dùng phải chọn từ danh sách bên dưới
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn một buổi học từ danh sách "Buổi cần bù" bên dưới.')),
              );
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            label: const Text('Đăng ký bù', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Widget xây dựng danh sách "Buổi cần bù"
  Widget _buildPendingMakeupSection() {
    return FutureBuilder<List<PendingMakeupItem>>(
      future: _pendingMakeupFuture,
      builder: (context, snapshot) {
        final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
        final title = 'Buổi cần bù (${snapshot.hasData ? snapshot.data!.length : 0})';

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: theme,
            child: ExpansionTile(
              initiallyExpanded: true, // Mặc định mở rộng
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(padding: EdgeInsets.all(20.0), child: Center(child: CircularProgressIndicator())),
                if (snapshot.hasError)
                  Padding(padding: const EdgeInsets.all(20.0), child: Center(child: Text('Lỗi: ${snapshot.error}'))),
                if (snapshot.hasData)
                  if (snapshot.data!.isEmpty)
                    const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('Không có buổi nào cần bù.')))
                  else
                    ...snapshot.data!.map((item) => ScheduleDetailItem(
                      item: item, // Truyền toàn bộ object vào
                      showMakeupButton: true,
                      userId: widget.userId, // Truyền userId để dùng cho điều hướng
                      onUpdate: _loadData, // Callback để tải lại dữ liệu
                    )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget xây dựng "Lịch sử nghỉ"
  Widget _buildHistorySection() {
    return FutureBuilder<List<LeaveHistoryItem>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
        final title = 'Lịch sử nghỉ (${snapshot.hasData ? snapshot.data!.length : 0})';

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: theme,
            child: ExpansionTile(
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(padding: EdgeInsets.all(20.0), child: Center(child: CircularProgressIndicator())),
                if (snapshot.hasError)
                  Padding(padding: const EdgeInsets.all(20.0), child: Center(child: Text('Lỗi: ${snapshot.error}'))),
                if (snapshot.hasData)
                  if (snapshot.data!.isEmpty)
                    const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('Chưa có lịch sử nghỉ dạy.')))
                  else
                    ...snapshot.data!.map((item) => LeaveHistoryDetailItem(item: item)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

//==================================================================
// MÀN HÌNH 2: ĐĂNG KÝ NGHỈ DẠY
//==================================================================
class RegisterLeaveScreen extends StatefulWidget {
  final int userId;
  const RegisterLeaveScreen({super.key, required this.userId});

  @override
  State<RegisterLeaveScreen> createState() => _RegisterLeaveScreenState();
}

class _RegisterLeaveScreenState extends State<RegisterLeaveScreen> {
  final ApiService _apiService = ApiService();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Future<List<AvailableSchedule>> _schedulesFuture;
  int? _selectedScheduleId;
  // File? _documentFile; // Dành cho upload file
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _apiService.fetchAvailableSchedulesForLeave(widget.userId);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return; // Validate form

    setState(() => _isSubmitting = true);
    try {
      await _apiService.submitLeaveRequest(
        userId: widget.userId,
        scheduleId: _selectedScheduleId!,
        reason: _reasonController.text,
        // document: _documentFile,
      );

      if (mounted) {
        final confirmed = await showSuccessDialog(context, 'Gửi yêu cầu nghỉ dạy thành công. Vui lòng chờ duyệt.');
        if (confirmed == true && mounted) {
          // Trả về 'true' để màn hình trước biết cần tải lại dữ liệu
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) showErrorDialog(context, "Lỗi: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // (Hàm chọn file, ví dụ)
  // Future<void> _pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     setState(() {
  //       _documentFile = File(result.files.single.path!);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Đăng ký nghỉ dạy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1, centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn buổi học:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              // Dropdown động
              FutureBuilder<List<AvailableSchedule>>(
                future: _schedulesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Không có lịch dạy nào sắp tới để đăng ký nghỉ.')),
                    );
                  }

                  final schedules = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: DropdownButtonFormField<int>(
                      value: _selectedScheduleId,
                      isExpanded: true,
                      hint: const Text('Chọn lịch dạy'),
                      decoration: const InputDecoration(border: InputBorder.none),
                      validator: (value) => value == null ? 'Vui lòng chọn một buổi học' : null,
                      onChanged: (int? newValue) {
                        setState(() => _selectedScheduleId = newValue);
                      },
                      items: schedules.map((schedule) {
                        return DropdownMenuItem<int>(
                          value: schedule.scheduleId,
                          child: Text(schedule.displayName, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Lý do nghỉ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Vd; Giảng viên bận công tác đột xuất...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập lý do' : null,
              ),
              const SizedBox(height: 24),
              const Text('Minh chứng (nếu có):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              // (Giao diện upload file)
              GestureDetector(
                // onTap: _pickFile,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
                  child: const Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.upload_file, size: 40, color: Colors.grey),
                      SizedBox(height: 8), Text('Tải ảnh hoặc file lên'),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSubmitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('Gửi yêu cầu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

//==================================================================
// MÀN HÌNH 3: ĐĂNG KÝ DẠY BÙ
//==================================================================
class RegisterMakeupScreen extends StatefulWidget {
  final int userId;
  final PendingMakeupItem item; // Nhận thông tin buổi cần bù

  const RegisterMakeupScreen({super.key, required this.userId, required this.item});

  @override
  State<RegisterMakeupScreen> createState() => _RegisterMakeupScreenState();
}

class _RegisterMakeupScreenState extends State<RegisterMakeupScreen> {
  final ApiService _apiService = ApiService();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // State cho form
  DateTime? _newDate;
  String? _newSession; // Ví dụ: "Tiết 1-3"
  int? _newRoomId;     // Ví dụ: 101

  // Dữ liệu tạm thời cho dropdowns (nên lấy từ API trong thực tế)
  final List<String> _sessions = ['Tiết 1-3', 'Tiết 4-6', 'Tiết 7-9', 'Tiết 10-12'];
  final Map<int, String> _rooms = {101: 'Phòng 101-B5', 102: 'Phòng 202-B5'};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitMakeup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _apiService.submitMakeupRequest(
        userId: widget.userId,
        originalScheduleId: widget.item.scheduleId,
        newDate: _newDate!,
        newSession: _newSession!,
        newRoomId: _newRoomId!,
        note: _noteController.text,
      );
      if (mounted) {
        final confirmed = await showSuccessDialog(context, 'Đăng ký dạy bù thành công. Vui lòng chờ duyệt.');
        if (confirmed == true && mounted) {
          // Pop về màn hình chính và báo cho nó tải lại
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) showErrorDialog(context, "Lỗi: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Đăng ký dạy bù', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1, centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Buổi học đã nghỉ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              // Hiển thị thông tin buổi nghỉ
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade200)),
                child: ScheduleDetailItem(item: widget.item, showMakeupButton: false, userId: widget.userId, onUpdate: () {}),
              ),
              const SizedBox(height: 24),

              // --- Form đăng ký ---
              // Chọn ngày bù
              const Text('Chọn ngày dạy bù:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)));
                  if (picked != null) setState(() => _newDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Text(_newDate == null ? 'dd/mm/yyyy' : DateFormat('dd/MM/yyyy').format(_newDate!)),
                ),
              ),
              const SizedBox(height: 16),

              // Chọn ca bù
              const Text('Chọn ca dạy bù:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _newSession,
                hint: const Text('Chọn ca/tiết học'),
                decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))),
                validator: (v) => v == null ? 'Vui lòng chọn ca học' : null,
                items: _sessions.map((session) => DropdownMenuItem(value: session, child: Text(session))).toList(),
                onChanged: (value) => setState(() => _newSession = value),
              ),
              const SizedBox(height: 16),

              // Chọn phòng bù
              const Text('Chọn phòng học:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _newRoomId,
                hint: const Text('Chọn phòng học'),
                decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))),
                validator: (v) => v == null ? 'Vui lòng chọn phòng học' : null,
                items: _rooms.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
                onChanged: (value) => setState(() => _newRoomId = value),
              ),
              const SizedBox(height: 16),

              // Ghi chú
              const Text('Ghi chú:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ghi chú thêm (nếu có)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitMakeup,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSubmitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('Gửi yêu cầu bù', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

//==================================================================
// WIDGET TÁI SỬ DỤNG CHO CHI TIẾT LỊCH HỌC
//==================================================================
class ScheduleDetailItem extends StatelessWidget {
  // Sửa lại để nhận một object thay vì nhiều biến
  final PendingMakeupItem item;
  final bool showMakeupButton;
  final int userId;
  final VoidCallback onUpdate; // Callback để tải lại dữ liệu

  const ScheduleDetailItem({
    super.key,
    required this.item,
    this.showMakeupButton = false,
    required this.userId,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
      color: Colors.white,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4.0, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2.0))),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.timeRange, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(item.lessonPeriod, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.subjectName} ${item.courseCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3)),
                  const SizedBox(height: 6.0),
                  Row(children: [
                    Icon(Icons.location_on, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 4.0),
                    Text(item.location, style: TextStyle(color: Colors.blue[700], fontSize: 14)),
                  ]),
                  if (showMakeupButton) ...[
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterMakeupScreen(userId: userId, item: item)),
                          );
                          // Nếu màn hình đăng ký bù trả về true (nghĩa là đã gửi thành công), tải lại dữ liệu
                          if (result == true) onUpdate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade800,
                          elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Đăng ký dạy bù'),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget mới để hiển thị lịch sử nghỉ
class LeaveHistoryDetailItem extends StatelessWidget {
  final LeaveHistoryItem item;
  const LeaveHistoryDetailItem({super.key, required this.item});

  // Helper để lấy màu và text cho status
  (Color, String) _getStatusInfo(String status) {
    switch (status) {
      case 'approved': return (Colors.green, 'Đã duyệt');
      case 'rejected': return (Colors.red, 'Đã từ chối');
      case 'pending':
      default: return (Colors.orange, 'Chờ duyệt');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusText) = _getStatusInfo(item.leaveStatus);

    return Container(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.dateString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${item.subjectName} ${item.courseCode}', style: const TextStyle(color: Colors.black87, fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Text('Lý do: ${item.reason}', style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
          ],
        )
    );
  }
}

//==================================================================
// HÀM TÁI SỬ DỤNG ĐỂ HIỂN THỊ DIALOG
//==================================================================
// (Giữ nguyên showSuccessDialog và thêm showErrorDialog)

Future<bool?> showSuccessDialog(BuildContext context, String message) {
  if (!context.mounted) return Future.value(false);
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 10),
            const Text('Thành công!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Đóng'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}

Future<void> showErrorDialog(BuildContext context, String message) {
  if (!context.mounted) return Future.value();
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Row(children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text("Lỗi!")]),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Đóng"),
        )
      ],
    ),
  );
}