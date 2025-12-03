import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          "Pengaturan",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _settingItem("Notifikasi", Icons.notifications_outlined),
          const SizedBox(height: 10),
          _settingItem("Keamanan Akun", Icons.lock_outline),
          const SizedBox(height: 10),
          _settingItem("Bahasa", Icons.language_outlined),
          const SizedBox(height: 10),
          _settingItem("Privasi", Icons.privacy_tip_outlined),
          const SizedBox(height: 10),
          _settingItem("Tentang Aplikasi", Icons.info_outline),
        ],
      ),
    );
  }

  Widget _settingItem(String title, IconData icon) {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFE7C0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
