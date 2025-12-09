import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // State untuk switch
  bool orderNotification = true;
  bool promoNotification = false;
  bool appUpdateNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Pengaturan Notifikasi",
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
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: SwitchListTile(
              title: const Text("Notifikasi Pesanan"),
              value: orderNotification,
              onChanged: (val) {
                setState(() {
                  orderNotification = val;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: SwitchListTile(
              title: const Text("Promo & Penawaran"),
              value: promoNotification,
              onChanged: (val) {
                setState(() {
                  promoNotification = val;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: SwitchListTile(
              title: const Text("Update Aplikasi"),
              value: appUpdateNotification,
              onChanged: (val) {
                setState(() {
                  appUpdateNotification = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
