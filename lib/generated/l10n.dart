import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

// THIS IS A MOCK FILE TO BYPASS l10n ERRORS
// This file provides default strings and allows the app to run.
// The language switching logic in `profile_screen.dart` will not work
// with this file. To enable full localization, you must fix the
// `flutter gen-l10n` command issues.

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

  String get loginWelcome {
    return Intl.message('Chào mừng trở lại!', name: 'loginWelcome', desc: '', locale: locale.toString());
  }
  String get usernameHint {
    return Intl.message('Tên đăng nhập', name: 'usernameHint', desc: '', locale: locale.toString());
  }
  String get passwordHint {
    return Intl.message('Mật khẩu', name: 'passwordHint', desc: '', locale: locale.toString());
  }
  String get rememberMe {
    return Intl.message('Ghi nhớ đăng nhập', name: 'rememberMe', desc: '', locale: locale.toString());
  }
  String get forgotPassword {
    return Intl.message('Quên mật khẩu?', name: 'forgotPassword', desc: '', locale: locale.toString());
  }
  String get loginButton {
    return Intl.message('Đăng nhập', name: 'loginButton', desc: '', locale: locale.toString());
  }
  String get logoutDialogTitle {
    return Intl.message('Thông báo!', name: 'logoutDialogTitle', desc: '', locale: locale.toString());
  }
  String get logoutDialogContent {
    return Intl.message('Bạn có chắc chắn muốn đăng xuất?', name: 'logoutDialogContent', desc: '', locale: locale.toString());
  }
  String get cancelButton {
    return Intl.message('Hủy', name: 'cancelButton', desc: '', locale: locale.toString());
  }
  String get confirmButton {
    return Intl.message('Xác nhận', name: 'confirmButton', desc: '', locale: locale.toString());
  }
  String get personalInfo {
    return Intl.message('Thông tin cá nhân', name: 'personalInfo', desc: '', locale: locale.toString());
  }
  String get language {
    return Intl.message('Ngôn ngữ', name: 'language', desc: '', locale: locale.toString());
  }
  String get logoutButton {
    return Intl.message('Đăng xuất', name: 'logoutButton', desc: '', locale: locale.toString());
  }
  String get profileHeaderTitle {
    return Intl.message('Khoa: Công nghệ thông tin', name: 'profileHeaderTitle', desc: '', locale: locale.toString());
  }
  String get bottomNavHome {
    return Intl.message('Trang chủ', name: 'bottomNavHome', desc: '', locale: locale.toString());
  }
  String get bottomNavSchedule {
    return Intl.message('Lịch dạy', name: 'bottomNavSchedule', desc: '', locale: locale.toString());
  }
  String get bottomNavAttendance {
    return Intl.message('Điểm danh', name: 'bottomNavAttendance', desc: '', locale: locale.toString());
  }
  String get bottomNavLeave {
    return Intl.message('Nghỉ/Bù', name: 'bottomNavLeave', desc: '', locale: locale.toString());
  }
  String get bottomNavReport {
    return Intl.message('Báo cáo', name: 'bottomNavReport', desc: '', locale: locale.toString());
  }
  String get bottomNavProfile {
    return Intl.message('Tôi', name: 'bottomNavProfile', desc: '', locale: locale.toString());
  }
  String get birthDate {
    return Intl.message('Ngày sinh', name: 'birthDate', desc: '', locale: locale.toString());
  }
  String get gender {
    return Intl.message('Giới tính', name: 'gender', desc: '', locale: locale.toString());
  }
  String get email {
    return Intl.message('Email', name: 'email', desc: '', locale: locale.toString());
  }
  String get phone {
    return Intl.message('Số điện thoại', name: 'phone', desc: '', locale: locale.toString());
  }
  String get lecturerId {
    return Intl.message('Mã giảng viên', name: 'lecturerId', desc: '', locale: locale.toString());
  }
  String get department {
    return Intl.message('Bộ môn', name: 'department', desc: '', locale: locale.toString());
  }
  String get status {
    return Intl.message('Trạng thái', name: 'status', desc: '', locale: locale.toString());
  }
  String get genderValue {
    return Intl.message('Nam', name: 'genderValue', desc: '', locale: locale.toString());
  }
  String get departmentValue {
    return Intl.message('Hệ thống thông tin', name: 'departmentValue', desc: '', locale: locale.toString());
  }
  String get statusValue {
    return Intl.message('Đang công tác', name: 'statusValue', desc: '', locale: locale.toString());
  }
  String get vietnamese {
    return Intl.message('Tiếng Việt', name: 'vietnamese', desc: '', locale: locale.toString());
  }
  String get english {
    return Intl.message('English', name: 'english', desc: '', locale: locale.toString());
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// A simple mock for the Intl class
class Intl {
  static String message(String message, {required String name, String? desc, required String locale}) {
    if (locale == 'en') {
      return _en[name] ?? message;
    }
    return message;
  }

  static final Map<String, String> _en = {
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
    "english": "English"
  };
}
