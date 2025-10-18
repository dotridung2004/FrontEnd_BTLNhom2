import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../models/document.dart';
import '../widgets/document_dialog.dart';

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

  void _showCustomDialog({required String title, required String message, bool isConfirmation = false, VoidCallback? onConfirm}) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                    const SizedBox(height: 16),
                    Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 24),
                    isConfirmation
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.red))
                          ),
                          child: Text(localizations.cancelButton, style: const TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: Text(localizations.confirmButton, style: const TextStyle(color: Colors.white)),
                        )
                      ],
                    )
                        : Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50)),
                        child: Text(localizations.confirmButton, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8, right: 8,
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

  void _showDocumentDialog({Document? document}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => DocumentDialog(document: document),
    );

    if (result != null) {
      final localizations = AppLocalizations.of(context)!;
      if (document == null) { // Thêm mới
        setState(() {
          _documents.add(Document(id: _documents.length, title: result['title']!, filePath: result['filePath']));
        });
        _showCustomDialog(title: localizations.logoutDialogTitle, message: localizations.addSuccess);
      } else { // Sửa
        setState(() {
          final index = _documents.indexWhere((d) => d.id == document.id);
          if (index != -1) {
            _documents[index].title = result['title']!;
            _documents[index].filePath = result['filePath'];
          }
        });
        _showCustomDialog(title: localizations.logoutDialogTitle, message: localizations.editSuccess);
      }
    }
  }

  void _deleteDocument(int id) {
    final localizations = AppLocalizations.of(context)!;
    _showCustomDialog(
        title: localizations.logoutDialogTitle,
        message: localizations.deleteDocumentConfirmation,
        isConfirmation: true,
        onConfirm: () {
          Navigator.of(context).pop(); // Đóng dialog xác nhận
          setState(() {
            _documents.removeWhere((doc) => doc.id == id);
          });
          _showCustomDialog(title: localizations.logoutDialogTitle, message: localizations.deleteSuccess);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF2E7BC4),
            child: const Text('TLU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thuy Loi', style: TextStyle(color: Color(0xFF1e293b), fontSize: 18, fontWeight: FontWeight.bold)),
            Text('University', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none, color: Colors.grey[800], size: 30), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(backgroundColor: Color(0xFF2E7BC4), child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
          ),
        ],
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
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7BC4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16)
                              ),
                              child: Text(localizations.edit, style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _deleteDocument(doc.id),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16)
                              ),
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                        ),
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
    );
  }
}
