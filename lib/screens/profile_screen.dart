import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'Tiếng Việt';

  void _showLogoutDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Thông báo!"),
          content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _infoTile(Icons.cake_outlined, 'Ngày sinh', '15/5/1985'),
                    _infoTile(Icons.male_outlined, 'Giới tính', 'Nam'),
                    _infoTile(Icons.email_outlined, 'Email', 'dungkt@tlu.edu.vn'),
                    _infoTile(Icons.phone_outlined, 'Số điện thoại', '0386666666'),
                    _infoTile(Icons.badge_outlined, 'Mã giảng viên', 'GV001'),
                    _infoTile(Icons.business_center_outlined, 'Bộ môn', 'Hệ thống thông tin'),
                    _infoTile(Icons.info_outline, 'Trạng thái', 'Đang công tác', showDivider: false),
                  ],
                ),
              ),
            ),
            _buildLanguageSelector(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7BC4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      color: const Color(0xFFD6EAF8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF2E7BC4),
                child: Text('D', style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, size: 18, color: Colors.grey[700]),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text("Kiều Tuấn Dũng", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
          const SizedBox(height: 4),
          Text("Khoa: Công nghệ thông tin", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 16),
              Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
              const Spacer(),
              Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1e293b))),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.language_outlined),
        title: const Text("Ngôn ngữ"),
        children: [
          RadioListTile<String>(
            title: const Text('Tiếng Việt'),
            value: 'Tiếng Việt',
            groupValue: _selectedLanguage,
            onChanged: (value) => setState(() => _selectedLanguage = value!),
          ),
          RadioListTile<String>(
            title: const Text('Tiếng Anh'),
            value: 'Tiếng Anh',
            groupValue: _selectedLanguage,
            onChanged: (value) => setState(() => _selectedLanguage = value!),
          ),
        ],
      ),
    );
  }
}