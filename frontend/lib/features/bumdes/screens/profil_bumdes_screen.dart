import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/page_transitions.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/bumdes/screens/edit_profile_bumdes_screen.dart';
import 'package:frontend/features/bumdes/screens/product_screen.dart';
import 'package:frontend/features/shared/screens/hpp_screen.dart';

import 'package:frontend/features/shared/screens/setting_screen.dart';
import 'package:frontend/features/shared/screens/help_screen.dart';

class ProfileBumdesPage extends StatefulWidget {
  const ProfileBumdesPage({super.key});

  @override
  State<ProfileBumdesPage> createState() => _ProfileBumdesPageState();
}

class _ProfileBumdesPageState extends State<ProfileBumdesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      "Profil",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileBumdesPage(),
                          ),
                        );
                      },
                      child: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(width: 18),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "BUMDes",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Vivian',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        '0813-5635-3033',
                        style: TextStyle(fontSize: 13, color: AppColors.textLight),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Jl. Pettarani No. 30',
                        style: TextStyle(fontSize: 13, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    profileCard('Produk', Icons.inventory_2_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductPage()),
                      );
                    }),
                    const SizedBox(height: 12),

                    profileCard('Harga HPP', Icons.price_change_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HppPage()),
                      );
                    }),
                    const SizedBox(height: 12),

                    profileCard('Pengaturan', Icons.settings_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    }),
                    const SizedBox(height: 12),

                    profileCard('Bantuan', Icons.help_outline, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpPage()),
                      );
                    }),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showLogoutConfirmationDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: AppColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Keluar',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.overlay,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ).drive(Tween<double>(begin: 0.95, end: 1.0)),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppColors.surface,
              child: Container(
                width: 260,
                height: 170,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Apakah kamu yakin mau keluar?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                if (!mounted) return;
                                this.context.pushAndRemoveAllSmooth(
                                  const AuthScreen(),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 88,
                            height: 31,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.primary),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Ya",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 88,
                            height: 31,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Tidak",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget profileCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textLight),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
