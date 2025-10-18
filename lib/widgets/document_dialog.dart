import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../models/document.dart';

class DocumentDialog extends StatefulWidget {
  final Document? document;
  const DocumentDialog({super.key, this.document});

  @override
  State<DocumentDialog> createState() => _DocumentDialogState();
}

class _DocumentDialogState extends State<DocumentDialog> {
  late final TextEditingController _titleController;
  String? _filePath;
  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document?.title ?? '');
    _filePath = widget.document?.filePath;

    // Kích hoạt nút Lưu nếu tiêu đề đã có sẵn (trường hợp sửa)
    _isSaveButtonEnabled = _titleController.text.isNotEmpty;

    // Lắng nghe sự thay đổi trong ô tiêu đề để cập nhật trạng thái nút Lưu
    _titleController.addListener(() {
      final isEnabled = _titleController.text.isNotEmpty;
      if (_isSaveButtonEnabled != isEnabled) {
        setState(() {
          _isSaveButtonEnabled = isEnabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.isNotEmpty) {
      Navigator.of(context).pop({
        'title': _titleController.text,
        'filePath': _filePath,
      });
    }
  }

  void _pickFile() {
    setState(() {
      _filePath = _filePath == null ? 'tailieu_da_chon.pdf' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isEditing = widget.document != null;

    // Sử dụng widget Dialog làm gốc để đảm bảo các nút hoạt động đúng
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24), // Đảm bảo dialog không quá lớn
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2E7BC4), width: 4),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header của Dialog
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7BC4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          isEditing
                              ? localizations.editDocument
                              : localizations.addDocument,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              // Thân của Dialog
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "${localizations.title}...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(localizations.attachment,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_filePath == null) ...[
                              const Icon(Icons.upload_file,
                                  color: Colors.grey, size: 40),
                              const SizedBox(height: 8),
                              Text(localizations.pickFile,
                                  style: const TextStyle(color: Colors.grey)),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.attach_file,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(_filePath!,
                                          style: const TextStyle(
                                              color: Colors.black),
                                          overflow: TextOverflow.ellipsis)),
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Các nút hành động
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.red)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24)),
                          child: Text(localizations.cancelButton,
                              style: const TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSaveButtonEnabled ? _save : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              disabledBackgroundColor:
                              Colors.green.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24)),
                          child: Text(localizations.save,
                              style: const TextStyle(color: Colors.white)),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

