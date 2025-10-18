import 'package:flutter/material.dart';
import '../generated/l10n.dart'; // Sử dụng tệp giả lập

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('vi'); // Ngôn ngữ mặc định là Tiếng Việt

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    // Chỉ thay đổi nếu ngôn ngữ được hỗ trợ
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners(); // Thông báo cho các widget khác để cập nhật lại giao diện
  }
}
