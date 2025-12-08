import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'upload_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'petani/manage_screen.dart';

class HomePageBumdes extends StatelessWidget {
  final VoidCallback? onProductTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onTransactionTap;

  const HomePageBumdes({
    super.key,
    this.onProductTap,
    this.onChatTap,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage("assets/images/logo.png"),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "PanenKi",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = (constraints.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _dashboardCard(
                          icon: Icons.check_circle_outline,
                          title: 'Produk Aktif',
                          value: '12',
                          width: cardWidth,
                          showArrow: true,
                          onTap: onProductTap,
                        ),
                        _dashboardCard(
                          icon: Icons.monetization_on_outlined,
                          title: 'Transaksi',
                          subtitle: 'Bulan Ini',
                          value: '23',
                          width: cardWidth,
                          showArrow: true,
                          onTap: onTransactionTap,
                        ),
                        _dashboardCard(
                          icon: Icons.chat_bubble_outline,
                          title: 'Chat Unread',
                          value: '3',
                          width: cardWidth,
                          showArrow: true,
                          onTap: onChatTap,
                        ),
                        _dashboardCard(
                          icon: Icons.people_outline,
                          title: 'Kelola Petani',
                          value: '5',
                          width: cardWidth,
                          showArrow: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const KelolaPetaniScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                Column(
                  children: [
                    _activityCard(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: Colors.orange,
                      title: 'Order baru #ORD-2025-002',
                      subtitle: 'Gabah 50kg - Rp 325.000',
                      time: '2 jam lalu',
                      status: 'Menunggu',
                      statusColor: Colors.orange,
                    ),
                    _activityCard(
                      icon: Icons.local_shipping_outlined,
                      iconColor: Colors.blue,
                      title: 'Pengiriman #ORD-2025-001',
                      subtitle: 'Jagung 20kg - Rp 120.000',
                      time: '3 jam lalu',
                      status: 'Dikirim',
                      statusColor: Colors.blue,
                    ),
                    _activityCard(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      title: 'Selesai #ORD-2025-000',
                      subtitle: 'Gabah 30kg - Rp 195.000',
                      time: '1 hari lalu',
                      status: 'Selesai',
                      statusColor: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UploadProdukScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28, color: AppColors.white),
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required String value,
    required double width,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: AppColors.primary),
                if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle != null ? '$title · $subtitle' : title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
