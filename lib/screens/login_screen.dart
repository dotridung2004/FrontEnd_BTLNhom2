import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import các file cần thiết
import '../api_service.dart';
import '../table/user.dart';
import 'home_screen.dart'; // Màn hình cho Giáo viên
import 'student_home_screen.dart'; // Màn hình cho Sinh viên

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // --- TỐI ƯU 1: Cache instance của SharedPreferences ---
  // Chúng ta sẽ lấy nó 1 lần trong initState và dùng lại
  late final SharedPreferences _prefs;
  bool _isInitLoading = true; // Cờ để biết đang tải dữ liệu ban đầu

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// ---------------------------------------------------
  /// 🔄 CẬP NHẬT: Tải thông tin nhanh hơn
  /// ---------------------------------------------------
  Future<void> _loadSavedCredentials() async {
    // Lấy instance 1 lần và cache lại
    _prefs = await SharedPreferences.getInstance();

    final bool remembered = _prefs.getBool('rememberMe') ?? false;

    String? email;
    String? password;

    if (remembered) {
      // Đọc song song 2 key từ storage
      final credentials = await Future.wait([
        _storage.read(key: 'email'),
        _storage.read(key: 'password'),
      ]);
      email = credentials[0];
      password = credentials[1];
    }

    if (mounted) {
      setState(() {
        _rememberMe = remembered;
        if (remembered && email != null && password != null) {
          _emailController.text = email;
          _passwordController.text = password;
        }
        _isInitLoading = false; // Tải xong, sẵn sàng để build
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ---------------------------------------------------
  /// 🚀 TỐI ƯU: Hàm lưu trữ chạy ngầm
  /// ---------------------------------------------------
  /// Hàm này sẽ lưu trữ thông tin đăng nhập trong nền
  /// mà không bắt người dùng phải chờ.
  Future<void> _saveCredentialsInBackground(String email, String password) async {
    try {
      // Chạy song song tất cả các tác vụ lưu trữ
      await Future.wait([
        _prefs.setBool('rememberMe', _rememberMe),
        if (_rememberMe) ...[
          _storage.write(key: 'email', value: email),
          _storage.write(key: 'password', value: password),
        ] else ...[
          // Nếu không "Ghi nhớ", xoá key song song
          _storage.delete(key: 'email'),
          _storage.delete(key: 'password'),
        ]
      ]);
      debugPrint("Lưu trữ thông tin đăng nhập thành công.");
    } catch (e) {
      // Lỗi lưu trữ không nên cản trở người dùng
      debugPrint("Lỗi khi lưu trữ thông tin đăng nhập trong nền: $e");
    }
  }

  /// ---------------------------------------------------
  /// 🚀 TỐI ƯU: Hàm xử lý đăng nhập và điều hướng
  /// ---------------------------------------------------
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // 1. Gọi API login, API sẽ kiểm tra status
      final user = await _apiService.login(email, password);

      // 2. ✨ TỐI ƯU: Bắt đầu lưu trữ nhưng KHÔNG await
      // Tác vụ này sẽ chạy trong nền.
      _saveCredentialsInBackground(email, password);

      // 3. ✨ TỐI ƯU: Điều hướng NGAY LẬP TỨC
      if (mounted) {
        // Xác định màn hình đích
        Widget destinationScreen;
        if (user.role == 'teacher') {
          destinationScreen = HomeScreen(userId: user.id);
        } else if (user.role == 'student') {
          destinationScreen = StudentHomeScreen(userId: user.id);
        } else {
          // Xử lý các vai trò khác không được hỗ trợ
          throw Exception('Vai trò của bạn không được hỗ trợ để đăng nhập.');
        }

        // Chuyển màn hình
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );

        // return ngay lập tức, không cần đợi lưu trữ
        return;
      }
    } catch (e) {
      // Bắt tất cả các lỗi (sai pass, bị khóa, vai trò không hợp lệ,...)
      debugPrint('Lỗi đăng nhập: $e');
      if (mounted) {
        _showErrorDialog(e.toString());
        // ✨ SỬA LỖI: Tắt loading khi có lỗi
        setState(() => _isLoading = false);
      }
    }
    // ✨ SỬA LỖI: Đã loại bỏ 'finally' block để tránh lỗi
    // 'setState called after dispose' khi đăng nhập thành công.
  }

  void _showErrorDialog(String errorMessage) {
    // ... (Hàm này giữ nguyên, không cần thay đổi) ...
    final displayMessage = errorMessage.replaceFirst('Exception: ', '').replaceAll('❌ ', '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFef4444), size: 28),
            SizedBox(width: 12),
            Text('Đăng nhập thất bại'),
          ],
        ),
        content: Text(
          displayMessage,
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // --- (Các hàm build() và widget khác giữ nguyên, không cần thay đổi) ---

  @override
  Widget build(BuildContext context) {
    // --- TỐI ƯU: Hiển thị loading screen trong khi tải SharedPreferences ---
    if (_isInitLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ... Toàn bộ code giao diện của bạn giữ nguyên ...
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB8D9F5),
              Color(0xFFD4E9F7),
              Color(0xFFE8F4FB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 24),
                    const Text(
                      'Chào mừng trở lại !',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Mật khẩu',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: const Color(0xFF2E7BC4),
                        ),
                        const Text(
                          'Ghi nhớ đăng nhập',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7BC4),
                          disabledBackgroundColor:
                          const Color(0xFF2E7BC4).withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // ... (Hàm này giữ nguyên, không cần thay đổi) ...
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7BC4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7BC4).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'TLU',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thuy Loi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7BC4),
              ),
            ),
            Text(
              'University',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF2E7BC4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    // ... (Hàm này giữ nguyên, không cần thay đổi) ...
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748b)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF64748b),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}