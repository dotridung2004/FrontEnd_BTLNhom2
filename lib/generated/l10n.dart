import 'package:flutter/widgets.dart';

// ĐÂY LÀ PHIÊN BẢN GIẢ LẬP CỦA AppLocalizations

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', ''),
    Locale('vi', ''),
  ];

  // --- Các chuỗi văn bản (Mặc định là Tiếng Việt) ---

  String get loginWelcome => "Chào mừng trở lại!";
  String get usernameHint => "Tên đăng nhập";
  String get passwordHint => "Mật khẩu";
  String get rememberMe => "Ghi nhớ đăng nhập";
  String get forgotPassword => "Quên mật khẩu?";
  String get loginButton => "Đăng nhập";
  String get logoutDialogTitle => "Thông báo!";
  String get logoutDialogContent => "Bạn có chắc chắn muốn đăng xuất?";
  String get cancelButton => "Hủy";
  String get confirmButton => "Xác nhận";
  String get personalInfo => "Thông tin cá nhân";
  String get language => "Ngôn ngữ";
  String get logoutButton => "Đăng xuất";
  String get profileHeaderTitle => "Khoa: Công nghệ thông tin";
  String get bottomNavHome => "Trang chủ";
  String get bottomNavSchedule => "Lịch dạy";
  String get bottomNavAttendance => "Điểm danh";
  String get bottomNavLeave => "Nghỉ/Bù";
  String get bottomNavReport => "Báo cáo";
  String get bottomNavProfile => "Tôi";
  String get birthDate => "Ngày sinh";
  String get gender => "Giới tính";
  String get email => "Email";
  String get phone => "Số điện thoại";
  String get lecturerId => "Mã giảng viên";
  String get department => "Bộ môn";
  String get status => "Trạng thái";
  String get genderValue => "Nam";
  String get departmentValue => "Hệ thống thông tin";
  String get statusValue => "Đang công tác";
  String get vietnamese => "Tiếng Việt";
  String get english => "English";
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}