import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Keamanan Akun",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      backgroundColor: AppColors.surfaceAlt,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSecurityCard(
            context,
            icon: Icons.lock_outline,
            title: "Ubah Password",
            onTap: () {
              // Navigasi ke halaman ubah password
            },
          ),
          const SizedBox(height: 16),
          _buildSecurityCard(
            context,
            icon: Icons.verified_user_outlined,
            title: "Autentikasi Dua Faktor",
            onTap: () {
              // Navigasi ke halaman autentikasi dua faktor
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textLight),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
