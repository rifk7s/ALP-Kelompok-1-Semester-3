import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'notifikasi_setting_screen.dart';
import 'security_screen.dart';
import 'about_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Pengaturan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _settingItem(
            context,
            "Notifikasi",
            Icons.notifications_outlined,
            const NotificationSettingsPage(),
          ),
          const SizedBox(height: 10),
          _settingItem(
            context,
            "Keamanan Akun",
            Icons.lock_outline,
            const SecuritySettingsPage(),
          ),
          const SizedBox(height: 10),
          _settingItem(
            context,
            "Tentang Aplikasi",
            Icons.info_outline,
            const AboutAppPage(),
          ),
        ],
      ),
    );
  }

  Widget _settingItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
