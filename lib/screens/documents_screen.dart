import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../models/document.dart';
import '../widgets/document_dialog.dart';
import '../widgets/confirmation_dialog.dart'; // Import tệp dialog mới

class DocumentsScreen extends StatefulWidget {
  final String courseTitle;
  const DocumentsScreen({super.key, required this.courseTitle});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<Document> _documents = [
    Document(id: 0, title: "L0- Giới thiệu môn học", filePath: "gioithieumonhoc.pdf"),
    Document(id: 1, title: "L1- Tổng quan về lập trình cho thiết bị di động"),
    Document(id: 2, title: "L2- Ngôn ngữ lập trình Dart"),
    Document(id: 3, title: "L3- Flutter cơ bản và Widgets"),
  ];

  // Hàm hiển thị hộp thoại Thêm/Sửa
  void _showDocumentDialog({Document? document}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DocumentDialog(document: document),
    );

    if (result != null && mounted) {
      final localizations = AppLocalizations.of(context)!;
      if (document == null) {
        setState(() {
          _documents.add(Document(id: _documents.length, title: result['title']!, filePath: result['filePath']));
        });
        showInfoDialog(context: context, title: localizations.logoutDialogTitle, message: localizations.addSuccess);
      } else {
        setState(() {
          final index = _documents.indexWhere((d) => d.id == document.id);
          if (index != -1) {
            _documents[index].title = result['title']!;
            _documents[index].filePath = result['filePath'];
          }
        });
        showInfoDialog(context: context, title: localizations.logoutDialogTitle, message: localizations.editSuccess);
      }
    }
  }

  // ✅ SỬA LỖI: Cập nhật hàm xóa để sử dụng async/await
  void _deleteDocument(int id) async {
    final localizations = AppLocalizations.of(context)!;

    // Chờ kết quả từ hộp thoại xác nhận
    final confirmed = await showConfirmationDialog(
      context: context,
      title: localizations.logoutDialogTitle,
      content: localizations.deleteDocumentConfirmation,
    );

    // Chỉ thực hiện hành động nếu người dùng nhấn "Xác nhận" (confirmed == true)
    if (confirmed == true && mounted) {
      setState(() {
        _documents.removeWhere((doc) => doc.id == id);
      });
      // Hiển thị thông báo thành công SAU KHI đã xóa
      showInfoDialog(context: context, title: localizations.logoutDialogTitle, message: localizations.deleteSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(localizations.documents, style: const TextStyle(color: Color(0xFF1e293b), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.courseTitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open, color: Color(0xFF1E88E5)),
                        const SizedBox(width: 8),
                        Text(localizations.courseDocuments, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _documents.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      return ListTile(
                        title: Text(doc.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showDocumentDialog(document: doc),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7BC4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16)),
                              child: Text(localizations.edit, style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _deleteDocument(doc.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16)),
                              child: Text(localizations.delete, style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () => _showDocumentDialog(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                        child: Text(localizations.add, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7BC4),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          Navigator.of(context).pop(index);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: localizations.bottomNavHome),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today_outlined), label: localizations.bottomNavSchedule),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle_outline), label: localizations.bottomNavAttendance),
          BottomNavigationBarItem(icon: const Icon(Icons.access_time_outlined), label: localizations.bottomNavLeave),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), label: localizations.bottomNavReport),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: localizations.bottomNavProfile),
        ],
      ),
    );
  }
}