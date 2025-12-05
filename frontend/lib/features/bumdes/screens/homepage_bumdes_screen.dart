import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'upload_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'petani/manage_screen.dart';

class HomePageBumdes extends StatelessWidget {
  final VoidCallback? onProductTap;
  final VoidCallback? onChatTap;

  const HomePageBumdes({super.key, this.onProductTap, this.onChatTap});

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                          icon: Icons.shopping_bag,
                          title: 'Produk',
                          value: '12',
                          width: cardWidth,
                          onTap: onProductTap,
                        ),
                        _dashboardCard(
                          icon: Icons.receipt,
                          title: 'Transaksi',
                          value: '23',
                          width: cardWidth,
                          onTap: () {},
                        ),
                        _dashboardCard(
                          icon: Icons.chat_bubble,
                          title: 'Chat',
                          value: '3',
                          width: cardWidth,
                          onTap: onChatTap,
                        ),
                        _dashboardCard(
                          icon: Icons.people,
                          title: 'Petani',
                          value: '5',
                          width: cardWidth,
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

                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _activityCard(
                      '📦 Order baru #ORD-2025-002',
                      'Gabah 50kg - Rp 325.000',
                      '2 jam lalu',
                    ),
                    _activityCard(
                      '📦 Order baru #ORD-2025-003',
                      'Jagung 20kg - Rp 120.000',
                      '3 jam lalu',
                    ),
                    _activityCard(
                      '📦 Order baru #ORD-2025-002',
                      'Gabah 50kg - Rp 325.000',
                      '2 jam lalu',
                    ),
                    _activityCard(
                      '📦 Order baru #ORD-2025-003',
                      'Jagung 20kg - Rp 120.000',
                      '3 jam lalu',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UploadProdukScreen()),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required double width,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
            Icon(icon, size: 30, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 5),
          Text(subtitle),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
