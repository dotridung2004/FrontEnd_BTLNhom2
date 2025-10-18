import 'package:flutter/material.dart';
import 'main_wrapper.dart';
import '../generated/l10n.dart'; // Sử dụng tệp giả lập

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  void _handleLogin() {
    // Trong tương lai, bạn có thể thêm logic kiểm tra username/password ở đây
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy đối tượng localizations một lần để dùng lại, giúp code gọn hơn
    final localizations = AppLocalizations.of(context)!;

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
              Color(0xFFE8F4FB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildLogo(),
                const SizedBox(height: 24),
                Text(
                  localizations.loginWelcome,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 50),
                _buildTextField(
                    hintText: localizations.usernameHint,
                    prefixIcon: Icons.person_outline
                ),
                const SizedBox(height: 20),
                _buildTextField(
                    hintText: localizations.passwordHint,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true
                ),
                const SizedBox(height: 20),
                _buildOptions(localizations),
                const SizedBox(height: 40),
                _buildLoginButton(localizations),
                const SizedBox(height: 40),
              ],
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
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7BC4),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'TLU',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thuy Loi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7BC4))),
            Text('University', style: TextStyle(fontSize: 16, color: Color(0xFF2E7BC4))),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({required String hintText, required IconData prefixIcon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF2E7BC4), width: 2),
        ),
      ),
    );
  }

  Widget _buildOptions(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value ?? false),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: const Color(0xFF2E7BC4),
            ),
            Text(localizations.rememberMe, style: const TextStyle(color: Color(0xFF475569))),
          ],
        ),
        TextButton(
          onPressed: () {
            // Thêm chức năng xử lý quên mật khẩu ở đây
          },
          child: Text(
            localizations.forgotPassword,
            style: const TextStyle(color: Color(0xFFef4444), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E7BC4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        child: Text(
          localizations.loginButton,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
