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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document?.title ?? '');
    _filePath = widget.document?.filePath;
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isEditing = widget.document != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2E7BC4), width: 4),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        isEditing ? localizations.editDocument : localizations.addDocument,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            // Body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "${localizations.title}...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(localizations.attachment, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      // ✅ SỬA LỖI: Thay thế kiểu viền không hợp lệ
                      border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_filePath == null) ...[
                          const Icon(Icons.upload_file, color: Colors.grey, size: 40),
                          const SizedBox(height: 8),
                          Text(localizations.pickFile, style: const TextStyle(color: Colors.grey)),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.attach_file, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_filePath!, style: const TextStyle(color: Colors.black), overflow: TextOverflow.ellipsis)),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.red)),
                            padding: const EdgeInsets.symmetric(horizontal: 24)
                        ),
                        child: Text(localizations.cancelButton, style: const TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24)
                        ),
                        child: Text(localizations.save, style: const TextStyle(color: Colors.white)),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

