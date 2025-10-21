import 'package:flutter/material.dart';

// 👇 THÊM 3 IMPORT
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart'; // 👈 import ApiService

//
import '../table/user.dart'; // 👈 import model User
import 'home_screen.dart';

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
  // 👇 KHỞI TẠO BỘ LƯU TRỮ AN TOÀN
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // 👇 Gọi hàm tải dữ liệu đã lưu khi màn hình khởi động
    _loadSavedCredentials();
  }

  /// ---------------------------------------------------
  /// 🌍 HÀM MỚI: Tải dữ liệu đã lưu
  /// ---------------------------------------------------
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    // Lấy trạng thái checkbox "remember me"
    final bool remembered = prefs.getBool('rememberMe') ?? false;

    setState(() {
      _rememberMe = remembered;
    });

    if (_rememberMe) {
      // Nếu đã lưu, lấy email và password từ bộ nhớ an toàn
      final email = await _storage.read(key: 'email');
      final password = await _storage.read(key: 'password');
      if (email != null && password != null) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ---------------------------------------------------
  /// 🔄 CẬP NHẬT: Hàm xử lý đăng nhập
  /// ---------------------------------------------------
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final prefs = await SharedPreferences.getInstance();

    try {
      final user = await _apiService.login(email, password);

      // --- 👇 LOGIC LƯU TRỮ MỚI 👇 ---
      // Lưu trạng thái checkbox
      await prefs.setBool('rememberMe', _rememberMe);

      if (_rememberMe) {
        // Nếu "Ghi nhớ" được chọn, LƯU email và password
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'password', value: password);
      } else {
        // Nếu không, XÓA mọi thông tin đã lưu
        await _storage.delete(key: 'email');
        await _storage.delete(key: 'password');
      }
      // --- 👆 KẾT THÚC LOGIC LƯU TRỮ 👆 ---

      // Đăng nhập thành công, chuyển màn hình
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: user.id),
          ),
        );
      }
    } catch (e) {
      // Nếu API báo lỗi (sai email/pass, bị khóa,...), hiển thị lỗi
      debugPrint('Lỗi đăng nhập: $e');
      if (mounted) {
        // 👇 SỬA LẠI: Truyền thông báo lỗi động
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ---------------------------------------------------
  /// 🔄 CẬP NHẬT: Hiển thị lỗi động
  /// ---------------------------------------------------
  void _showErrorDialog(String errorMessage) {
    // Làm sạch thông báo lỗi (bỏ "Exception: " và "❌ ")
    final displayMessage = errorMessage
        .replaceFirst('Exception: ', '')
        .replaceAll('❌ ', '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFef4444), size: 28),
            SizedBox(width: 12),
            Text('Đăng nhập thất bại'),
          ],
        ),
        // 👇 SỬA LẠI: Hiển thị lỗi thực tế từ API
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

  // --- (Các hàm build() và widget khác giữ nguyên) ---

  @override
  Widget build(BuildContext context) {
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
                    // Sửa lại TextField để nhập Email
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