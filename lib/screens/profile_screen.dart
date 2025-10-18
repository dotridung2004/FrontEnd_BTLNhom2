import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import 'login_screen.dart';
import '../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  void _showLogoutDialog(AppLocalizations localizations) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(localizations.logoutDialogTitle),
          content: Text(localizations.logoutDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancelButton, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(localizations.confirmButton, style: const TextStyle(color: Colors.white)),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(localizations),
            const SizedBox(height: 20), // Thêm khoảng cách sau header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildExpansionCard(
                    title: localizations.personalInfo,
                    icon: Icons.person_outline,
                    children: [
                      _infoTile(Icons.cake_outlined, localizations.birthDate, '15/5/1985'),
                      _infoTile(Icons.male_outlined, localizations.gender, localizations.genderValue),
                      _infoTile(Icons.email_outlined, localizations.email, 'dungkt@tlu.edu.vn'),
                      _infoTile(Icons.phone_outlined, localizations.phone, '0386666666'),
                      _infoTile(Icons.badge_outlined, localizations.lecturerId, 'GV001'),
                      _infoTile(Icons.business_center_outlined, localizations.department, localizations.departmentValue),
                      _infoTile(Icons.info_outline, localizations.status, localizations.statusValue, showDivider: false),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildExpansionCard(
                    title: localizations.language,
                    icon: Icons.language_outlined,
                    initiallyExpanded: false,
                    children: [
                      RadioListTile<Locale>(
                        title: Text(localizations.vietnamese),
                        value: const Locale('vi'),
                        groupValue: localeProvider.locale,
                        onChanged: (Locale? value) {
                          if (value != null) {
                            localeProvider.setLocale(value);
                          }
                        },
                        activeColor: const Color(0xFF2E7BC4),
                      ),
                      RadioListTile<Locale>(
                        title: Text(localizations.english),
                        value: const Locale('en'),
                        groupValue: localeProvider.locale,
                        onChanged: (Locale? value) {
                          if (value != null) {
                            localeProvider.setLocale(value);
                          }
                        },
                        activeColor: const Color(0xFF2E7BC4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Thêm khoảng cách trước nút đăng xuất
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(localizations),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7BC4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(localizations.logoutButton, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
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
          Text(localizations.profileHeaderTitle, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildExpansionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        initiallyExpanded: initiallyExpanded,
        children: children,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
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
        if (showDivider) Divider(height: 1, color: Colors.grey[200], indent: 16, endIndent: 16),
      ],
    );
  }
}

