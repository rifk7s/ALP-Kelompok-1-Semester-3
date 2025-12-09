import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),

      body: ListView(
        children: [
          notifItem(
            title: "Pesanan kamu telah dikirim!",
            message: "Kurir sedang menuju lokasi kamu.",
            time: "2 menit lalu",
            isUnread: true,
            icon: Icons.local_shipping,
          ),
          notifItem(
            title: "Voucher khusus buat kamu!",
            message: "Diskon 30% berlaku untuk semua kategori.",
            time: "1 jam lalu",
            isUnread: false,
            icon: Icons.discount,
          ),
          notifItem(
            title: "Keamanan Akun",
            message: "Login baru terdeteksi di perangkat lain.",
            time: "Kemarin",
            isUnread: false,
            icon: Icons.security,
          ),
          notifItem(
            title: "Promo Gratis Ongkir",
            message: "Cek segera sebelum kehabisan!",
            time: "2 hari lalu",
            isUnread: false,
            icon: Icons.card_giftcard,
          ),
        ],
      ),
    );
  }

  Widget notifItem({
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.notificationCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(fontSize: 13, color: AppColors.grey800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.notificationDivider),
        ],
      ),
    );
  }
}
