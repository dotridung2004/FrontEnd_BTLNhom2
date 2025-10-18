import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

// ĐÂY LÀ PHIÊN BẢN GIẢ LẬP ĐÃ SỬA LẠI ĐỂ HOẠT ĐỘNG CHÍNH XÁC
// Nó cho phép chuyển đổi ngôn ngữ cho toàn bộ ứng dụng mà không cần
// chạy lệnh `flutter gen-l10n`.

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

  // --- Bảng tra cứu ngôn ngữ ---

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      "loginWelcome": "Welcome Back!",
      "usernameHint": "Username",
      "passwordHint": "Password",
      "rememberMe": "Remember me",
      "forgotPassword": "Forgot Password?",
      "loginButton": "Login",
      "logoutDialogTitle": "Notification!",
      "logoutDialogContent": "Are you sure you want to log out?",
      "cancelButton": "Cancel",
      "confirmButton": "Confirm",
      "personalInfo": "Personal Information",
      "language": "Language",
      "logoutButton": "Logout",
      "profileHeaderTitle": "Faculty of Information Technology",
      "bottomNavHome": "Home",
      "bottomNavSchedule": "Schedule",
      "bottomNavAttendance": "Attendance",
      "bottomNavLeave": "Leave/Make-up",
      "bottomNavReport": "Report",
      "bottomNavProfile": "Me",
      "birthDate": "Date of Birth",
      "gender": "Gender",
      "email": "Email",
      "phone": "Phone Number",
      "lecturerId": "Lecturer ID",
      "department": "Department",
      "status": "Status",
      "genderValue": "Male",
      "departmentValue": "Information Systems",
      "statusValue": "Working",
      "vietnamese": "Tiếng Việt",
      "english": "English",
      "attendanceSaved": "Saved"
    },
    'vi': {
      "loginWelcome": "Chào mừng trở lại!",
      "usernameHint": "Tên đăng nhập",
      "passwordHint": "Mật khẩu",
      "rememberMe": "Ghi nhớ đăng nhập",
      "forgotPassword": "Quên mật khẩu?",
      "loginButton": "Đăng nhập",
      "logoutDialogTitle": "Thông báo!",
      "logoutDialogContent": "Bạn có chắc chắn muốn đăng xuất?",
      "cancelButton": "Hủy",
      "confirmButton": "Xác nhận",
      "personalInfo": "Thông tin cá nhân",
      "language": "Ngôn ngữ",
      "logoutButton": "Đăng xuất",
      "profileHeaderTitle": "Khoa: Công nghệ thông tin",
      "bottomNavHome": "Trang chủ",
      "bottomNavSchedule": "Lịch dạy",
      "bottomNavAttendance": "Điểm danh",
      "bottomNavLeave": "Nghỉ/Bù",
      "bottomNavReport": "Báo cáo",
      "bottomNavProfile": "Tôi",
      "birthDate": "Ngày sinh",
      "gender": "Giới tính",
      "email": "Email",
      "phone": "Số điện thoại",
      "lecturerId": "Mã giảng viên",
      "department": "Bộ môn",
      "status": "Trạng thái",
      "genderValue": "Nam",
      "departmentValue": "Hệ thống thông tin",
      "statusValue": "Đang công tác",
      "vietnamese": "Tiếng Việt",
      "english": "English",
      "attendanceSaved": "Đã lưu"
    },
  };

  // Hàm tra cứu chung
  String _lookup(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['vi']![key]!;
  }

  // --- Getters ---
  String get loginWelcome => _lookup('loginWelcome');
  String get usernameHint => _lookup('usernameHint');
  String get passwordHint => _lookup('passwordHint');
  String get rememberMe => _lookup('rememberMe');
  String get forgotPassword => _lookup('forgotPassword');
  String get loginButton => _lookup('loginButton');
  String get logoutDialogTitle => _lookup('logoutDialogTitle');
  String get logoutDialogContent => _lookup('logoutDialogContent');
  String get cancelButton => _lookup('cancelButton');
  String get confirmButton => _lookup('confirmButton');
  String get personalInfo => _lookup('personalInfo');
  String get language => _lookup('language');
  String get logoutButton => _lookup('logoutButton');
  String get profileHeaderTitle => _lookup('profileHeaderTitle');
  String get bottomNavHome => _lookup('bottomNavHome');
  String get bottomNavSchedule => _lookup('bottomNavSchedule');
  String get bottomNavAttendance => _lookup('bottomNavAttendance');
  String get bottomNavLeave => _lookup('bottomNavLeave');
  String get bottomNavReport => _lookup('bottomNavReport');
  String get bottomNavProfile => _lookup('bottomNavProfile');
  String get birthDate => _lookup('birthDate');
  String get gender => _lookup('gender');
  String get email => _lookup('email');
  String get phone => _lookup('phone');
  String get lecturerId => _lookup('lecturerId');
  String get department => _lookup('department');
  String get status => _lookup('status');
  String get genderValue => _lookup('genderValue');
  String get departmentValue => _lookup('departmentValue');
  String get statusValue => _lookup('statusValue');
  String get vietnamese => _lookup('vietnamese');
  String get english => _lookup('english');
  String get attendanceSaved => _lookup('attendanceSaved');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here is because we don't need to
    // load the translations from a file.
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

