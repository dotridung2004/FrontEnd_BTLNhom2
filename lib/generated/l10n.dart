import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

// ĐÂY LÀ PHIÊN BẢN GIẢ LẬP ĐÃ SỬA LẠI ĐỂ HOẠT ĐỘNG CHÍNH XÁC

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

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      "loginWelcome": "Welcome Back!", "usernameHint": "Username", "passwordHint": "Password", "rememberMe": "Remember me", "forgotPassword": "Forgot Password?", "loginButton": "Login", "logoutDialogTitle": "Notification!", "logoutDialogContent": "Are you sure you want to log out?", "cancelButton": "Cancel", "confirmButton": "Confirm", "personalInfo": "Personal Information", "language": "Language", "logoutButton": "Logout", "profileHeaderTitle": "Faculty of Information Technology", "bottomNavHome": "Home", "bottomNavSchedule": "Schedule", "bottomNavAttendance": "Attendance", "bottomNavLeave": "Leave/Make-up", "bottomNavReport": "Report", "bottomNavProfile": "Me", "birthDate": "Date of Birth", "gender": "Gender", "email": "Email", "phone": "Phone Number", "lecturerId": "Lecturer ID", "department": "Department", "status": "Status", "genderValue": "Male", "departmentValue": "Information Systems", "statusValue": "Working", "vietnamese": "Tiếng Việt", "english": "English", "loadStudentList": "Load Student List", "saveAttendance": "Save Attendance", "selectClass": "Select Class", "present": "Present", "absent": "Absent", "late": "Late", "attendanceSaved": "Saved", "notification": "Notification!", "confirm": "Confirm",

      // MỚI: Thêm các khóa cho chức năng tài liệu
      "documents": "Documents",
      "courseDocuments": "Course Documents - Lectures",
      "add": "Add",
      "edit": "Edit",
      "delete": "Delete",
      "addDocument": "Add Document",
      "editDocument": "Edit Document",
      "title": "Title",
      "attachment": "Attachment",
      "pickFile": "Choose file or drag & drop",
      "save": "Save",
      "deleteDocumentConfirmation": "Are you sure you want to delete this document?",
      "deleteSuccess": "Document deleted successfully.",
      "editSuccess": "Document updated successfully.",
      "addSuccess": "Document added successfully."
    },
    'vi': {
      "loginWelcome": "Chào mừng trở lại!", "usernameHint": "Tên đăng nhập", "passwordHint": "Mật khẩu", "rememberMe": "Ghi nhớ đăng nhập", "forgotPassword": "Quên mật khẩu?", "loginButton": "Đăng nhập", "logoutDialogTitle": "Thông báo!", "logoutDialogContent": "Bạn có chắc chắn muốn đăng xuất?", "cancelButton": "Hủy", "confirmButton": "Xác nhận", "personalInfo": "Thông tin cá nhân", "language": "Ngôn ngữ", "logoutButton": "Đăng xuất", "profileHeaderTitle": "Khoa: Công nghệ thông tin", "bottomNavHome": "Trang chủ", "bottomNavSchedule": "Lịch dạy", "bottomNavAttendance": "Điểm danh", "bottomNavLeave": "Nghỉ/Bù", "bottomNavReport": "Báo cáo", "bottomNavProfile": "Tôi", "birthDate": "Ngày sinh", "gender": "Giới tính", "email": "Email", "phone": "Số điện thoại", "lecturerId": "Mã giảng viên", "department": "Bộ môn", "status": "Trạng thái", "genderValue": "Nam", "departmentValue": "Hệ thống thông tin", "statusValue": "Đang công tác", "vietnamese": "Tiếng Việt", "english": "English", "loadStudentList": "Tải danh sách sinh viên", "saveAttendance": "Lưu điểm danh", "selectClass": "Chọn lớp", "present": "Có mặt", "absent": "Vắng", "late": "Muộn", "attendanceSaved": "Đã lưu", "notification": "Thông báo!", "confirm": "Xác nhận",

      // MỚI: Thêm các khóa cho chức năng tài liệu
      "documents": "Tài liệu",
      "courseDocuments": "Tài liệu - Bài giảng",
      "add": "Thêm",
      "edit": "Sửa",
      "delete": "Xóa",
      "addDocument": "Thêm tài liệu",
      "editDocument": "Sửa tài liệu",
      "title": "Tiêu đề",
      "attachment": "Tài liệu đính kèm",
      "pickFile": "Chọn file hoặc kéo thả",
      "save": "Lưu",
      "deleteDocumentConfirmation": "Bạn có chắc chắn muốn xóa tài liệu?",
      "deleteSuccess": "Xóa tài liệu thành công.",
      "editSuccess": "Sửa tài liệu thành công.",
      "addSuccess": "Thêm tài liệu thành công."
    },
  };

  String _lookup(String key) { return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['vi']![key]!; }

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
  String get loadStudentList => _lookup('loadStudentList');
  String get saveAttendance => _lookup('saveAttendance');
  String get selectClass => _lookup('selectClass');
  String get present => _lookup('present');
  String get absent => _lookup('absent');
  String get late => _lookup('late');
  String get attendanceSaved => _lookup('attendanceSaved');
  String get notification => _lookup('notification');
  String get confirm => _lookup('confirm');
  String get documents => _lookup('documents');
  String get courseDocuments => _lookup('courseDocuments');
  String get add => _lookup('add');
  String get edit => _lookup('edit');
  String get delete => _lookup('delete');
  String get addDocument => _lookup('addDocument');
  String get editDocument => _lookup('editDocument');
  String get title => _lookup('title');
  String get attachment => _lookup('attachment');
  String get pickFile => _lookup('pickFile');
  String get save => _lookup('save');
  String get deleteDocumentConfirmation => _lookup('deleteDocumentConfirmation');
  String get deleteSuccess => _lookup('deleteSuccess');
  String get editSuccess => _lookup('editSuccess');
  String get addSuccess => _lookup('addSuccess');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}

