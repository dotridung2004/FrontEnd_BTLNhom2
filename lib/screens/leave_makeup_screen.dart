import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Hàm main để chạy ứng dụng
void main() {
  runApp(const MyApp());
}

// Widget gốc của ứng dụng
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teaching Schedule UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      // Màn hình chính khi khởi động
      home: const LeaveAndMakeupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//==================================================================
// MÀN HÌNH 1: MÀN HÌNH NGHỈ/BÙ CHÍNH
//==================================================================
class LeaveAndMakeupScreen extends StatefulWidget {
  const LeaveAndMakeupScreen({super.key});

  @override
  State<LeaveAndMakeupScreen> createState() => _LeaveAndMakeupScreenState();
}

class _LeaveAndMakeupScreenState extends State<LeaveAndMakeupScreen> {
  @override
  Widget build(BuildContext context) {
    final expansionTileTheme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Buổi đã nghỉ: 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Buổi cần bù:1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterLeaveScreen()),
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined, color: Colors.white, size: 28),
                        label: const Text('Đăng ký nghỉ dạy', style: TextStyle(color: Colors.white)),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterMakeupScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                        label: const Text('Đăng ký dạy bù', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: expansionTileTheme,
                    child: ExpansionTile(
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      title: const Text('Buổi cần bù(1)', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: const <Widget>[
                        ScheduleDetailItem(
                          timeRange: '9:45 - 12:25',
                          lessonPeriod: 'Tiết 4-6',
                          subjectName: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
                          courseCode: 'CSE441_002',
                          location: '207 - B5',
                          showMakeupButton: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: expansionTileTheme,
                    child: const ExpansionTile(
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      title: Text('Lịch sử nghỉ', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: <Widget>[
                        ScheduleDetailItem(
                          timeRange: '9:45 - 12:25',
                          lessonPeriod: 'Tiết 4-6',
                          subjectName: 'Phát triển ứng dụng cho các thiết bị di động-1-25',
                          courseCode: 'CSE441_002',
                          location: '207 - B5',
                          showMakeupButton: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//==================================================================
// MÀN HÌNH 2: ĐĂNG KÝ NGHỈ DẠY
//==================================================================
class RegisterLeaveScreen extends StatefulWidget {
  const RegisterLeaveScreen({super.key});

  @override
  State<RegisterLeaveScreen> createState() => _RegisterLeaveScreenState();
}

class _RegisterLeaveScreenState extends State<RegisterLeaveScreen> {
  File? _pickedFile;

  Future<void> _pickFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Đăng ký nghỉ dạy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('7:00 - 9:40', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('Tiết 1-3', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Phát triển ứng dụng cho các thiết bị di động-1-25 (CSE441_001)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.blue[700], size: 16),
                                        const SizedBox(width: 4),
                                        Text('210 - B5', style: TextStyle(color: Colors.blue[700])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Lý do nghỉ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Vd; Giảng viên bận công tác đột xuất...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Minh chứng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid, width: 1),
                  ),
                  child: Center(
                    child: _pickedFile == null
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tải ảnh hoặc file lên'),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 40),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _pickedFile!.path.split('/').last,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
          onPressed: () async {
            final confirmed = await showSuccessDialog(context, 'Gửi yêu cầu nghỉ dạy thành công.');
            if (confirmed == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Gửi yêu cầu nghỉ dạy', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

//==================================================================
// MÀN HÌNH 3: ĐĂNG KÝ DẠY BÙ
//==================================================================
class RegisterMakeupScreen extends StatefulWidget {
  const RegisterMakeupScreen({super.key});

  @override
  State<RegisterMakeupScreen> createState() => _RegisterMakeupScreenState();
}

class _RegisterMakeupScreenState extends State<RegisterMakeupScreen> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  String? _selectedShift;
  String? _selectedRoom;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ĐÃ SỬA: Thêm "Ca 3" vào danh sách
    final List<String> shifts = [
      'Ca 1: 7:00-9:40',
      'Ca 2: 9:45-12:20',
      'Ca 3: 12:55-3:40'
    ];
    final List<String> rooms = ['Phòng 207-B5', 'Phòng 210-B5'];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Đăng ký dạy bù', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('7:00 - 9:40', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('Tiết 1-3', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Thứ 5, Ngày 15/09/2025', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    const Text('Phát triển ứng dụng chi các thiết bị di động-1-25 (CSE441_001)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.blue[700], size: 16),
                                        const SizedBox(width: 4),
                                        Text('210 - B5', style: TextStyle(color: Colors.blue[700])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Chọn ngày dạy bù:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Chọn ca dạy bù:',
                hint: 'Chọn một ca học',
                value: _selectedShift,
                items: shifts,
                onChanged: (newValue) {
                  setState(() {
                    _selectedShift = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Chọn phòng học:',
                hint: 'Chọn một phòng học',
                value: _selectedRoom,
                items: rooms,
                onChanged: (newValue) {
                  setState(() {
                    _selectedRoom = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Ghi chú:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ghi chú thêm(nếu có):',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text('Hủy', style: TextStyle(color: Colors.black54, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showSuccessDialog(context, 'Đăng ký dạy bù thành công.');
                  if (confirmed == true && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Đăng ký', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: Colors.grey)),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

//==================================================================
// WIDGET TÁI SỬ DỤNG CHO CHI TIẾT LỊCH HỌC
//==================================================================
class ScheduleDetailItem extends StatelessWidget {
  final String timeRange;
  final String lessonPeriod;
  final String subjectName;
  final String courseCode;
  final String location;
  final bool showMakeupButton;

  const ScheduleDetailItem({
    super.key,
    required this.timeRange,
    required this.lessonPeriod,
    required this.subjectName,
    required this.courseCode,
    required this.location,
    this.showMakeupButton = false,
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
            Container(
              width: 4.0,
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2.0)),
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(timeRange, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(lessonPeriod, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$subjectName ($courseCode)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3)),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue[700], size: 16),
                      const SizedBox(width: 4.0),
                      Text(location, style: TextStyle(color: Colors.blue[700], fontSize: 14)),
                    ],
                  ),
                  if (showMakeupButton) ...[
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterMakeupScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade800,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

//==================================================================
// HÀM TÁI SỬ DỤNG ĐỂ HIỂN THỊ DIALOG THÔNG BÁO
//==================================================================
Future<bool?> showSuccessDialog(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thông báo!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              splashRadius: 20,
            ),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
        actionsAlignment: MainAxisAlignment.center,
      );
    },
  );
}