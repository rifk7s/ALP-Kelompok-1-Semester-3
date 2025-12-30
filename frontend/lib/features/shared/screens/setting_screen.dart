import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/widgets/app_cards.dart';

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
            color: AppColors.textLight,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.sm,
        ),
        children: [
          _settingItem(
            context,
            "Notifikasi",
            Icons.notifications_outlined,
            RoutePaths.notifications,
          ),
          const SizedBox(height: AppSpacing.sm),
          _settingItem(
            context,
            "Keamanan Akun",
            Icons.lock_outline,
            RoutePaths.settings,
          ),
          const SizedBox(height: AppSpacing.sm),
          _settingItem(
            context,
            "Tentang Aplikasi",
            Icons.info_outline,
            RoutePaths.about,
          ),
        ],
      ),
    );
  }

  Widget _settingItem(
    BuildContext context,
    String title,
    IconData icon,
    String routePath,
  ) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textLight),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.push(routePath);
        },
      ),
    );
  }
}
