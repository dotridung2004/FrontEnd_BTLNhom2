import 'package:flutter/material.dart';
import '../generated/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('vi'); // Ngôn ngữ mặc định là Tiếng Việt

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    // Kiểm tra xem ngôn ngữ được chọn có được hỗ trợ không
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    _locale = locale;

    // Thông báo cho các widget đang lắng nghe (như MaterialApp) để cập nhật lại
    notifyListeners();
  }
}

