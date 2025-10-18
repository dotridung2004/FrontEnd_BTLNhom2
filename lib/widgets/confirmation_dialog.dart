import 'package:flutter/material.dart';
import '../generated/l10n.dart';

// Widget hộp thoại xác nhận có thể tái sử dụng
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  final localizations = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                const SizedBox(height: 16),
                Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      // Trả về 'false' khi nhấn Hủy
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.red))
                      ),
                      child: Text(localizations.cancelButton, style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      // Trả về 'true' khi nhấn Xác nhận
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text(localizations.confirmButton, style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(false), // Trả về 'false' khi nhấn X
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget hộp thoại thông báo đơn giản
void showInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  final localizations = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 24),
                Center(
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
    ),
  );
}