import 'package:flutter/material.dart';
import '../table/user.dart'; // Import model User (phiên bản dùng String)
import '../api_service.dart'; // Import ApiService
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _userFuture;
  String _selectedLanguage = 'Tiếng Việt';

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().fetchUserById(widget.userId);
  }

  void _showLogoutDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
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
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Xác nhận",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa cập nhật';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // Sửa hàm helper để nhận `String?` (từ model)
  String _getGenderDisplay(String? gender) {
    switch (gender) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return 'Chưa cập nhật';
    }
  }

  // Sửa hàm helper để nhận `String` (từ model)
  String _getRoleDisplay(String role) {
    switch (role) {
      case 'student':
        return 'Sinh viên';
      case 'teacher':
        return 'Giảng viên';
      case 'training_office':
        return 'Phòng đào tạo';
      case 'head_of_department':
        return 'Trưởng khoa';
      default:
        return role.isNotEmpty ? role : 'Chưa cập nhật';
    }
  }

  // Sửa hàm helper để nhận `String` (từ model)
  String _getStatusDisplay(String status) {
    switch (status) {
      case 'active':
        return 'Đang hoạt động';
      case 'inactive':
        return 'Không hoạt động';
      case 'banned':
        return 'Đã bị cấm';
      default:
        return status.isNotEmpty ? status : 'Chưa cập nhật';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text('Không tìm thấy thông tin người dùng'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user),
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
                        _infoTile(Icons.cake_outlined, 'Ngày sinh',
                            _formatDate(user.dateOfBirth)),
                        _infoTile(Icons.male_outlined, 'Giới tính',
                            _getGenderDisplay(user.gender)),
                        _infoTile(Icons.email_outlined, 'Email', user.email),
                        _infoTile(
                            Icons.phone_outlined,
                            'Số điện thoại',
                            (user.phoneNumber?.isNotEmpty ?? false)
                                ? user.phoneNumber!
                                : 'Chưa cập nhật'),
                        // _infoTile(Icons.badge_outlined, 'Mã người dùng',
                        //     user.id.toString()),
                        _infoTile(Icons.business_center_outlined, 'Vai trò',
                            _getRoleDisplay(user.role)),
                        // _infoTile(Icons.info_outline, 'Trạng thái',
                        //     _getStatusDisplay(user.status),
                        //     showDivider: false),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Đăng xuất",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user) {
    final avatar = (user.avatarUrl?.isNotEmpty ?? false)
        ? NetworkImage(user.avatarUrl!)
        : null;
    final avatarLetter = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

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
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF2E7BC4),
                backgroundImage: avatar,
                child: avatar == null
                    ? Text(avatarLetter,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold))
                    : null,
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Chức năng chỉnh sửa sắp ra mắt!')),
                  );
                },
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.edit, size: 18, color: Colors.grey[700]),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(user.name.isNotEmpty ? user.name : 'Người dùng',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b))),
          const SizedBox(height: 4),
          Text("Email: ${user.email}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 16),
              Text(title,
                  style: TextStyle(color: Colors.grey[700], fontSize: 16)),
              const Spacer(),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1e293b))),
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