import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/core/services/profile_service.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/pembeli/screens/edit_profile_screen.dart';

import 'package:frontend/features/shared/screens/setting_screen.dart';
import 'package:frontend/features/shared/screens/help_screen.dart';
import 'package:frontend/features/shared/screens/hpp_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/transaction_history_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

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
                      onTap: () async {
                        // Navigate to edit profile with current user data
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              initialProfile: _user != null
                                  ? Profile(
                                      id: _user!['id'] as int,
                                      name: _user!['name'] as String,
                                      phone: _user!['phone'] as String?,
                                      address: _user!['address'] as String?,
                                      email: _user!['email'] as String?,
                                    )
                                  : null,
                            ),
                          ),
                        );

                        // Reload user data if profile was updated
                        if (result != null && mounted) {
                          await _loadUser();
                        }
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

                  Expanded(
                    child: Column(
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
                          child: Text(
                            (_user?['role'] ?? 'pembeli')
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _user?['name'] ?? 'Pengguna',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _user?['phone'] ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _user?['address'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    profileCard('Pesanan Saya', Icons.description_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryPage(),
                        ),
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
                          onTap: () async {
                            // Cache the navigator before popping dialog
                            final navigator = Navigator.of(context);
                            navigator.pop();

                            await AuthService.logout();

                            if (!mounted) return;

                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                              (route) => false,
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
