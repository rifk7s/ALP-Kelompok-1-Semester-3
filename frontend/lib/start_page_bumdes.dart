import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/auth/screens/bumdes/homepage_bumdes_screen.dart';
import 'package:frontend/features/auth/screens/bumdes/product_screen.dart';
import 'package:frontend/features/auth/screens/bumdes/contact_bumdes_screen.dart';
import 'package:frontend/features/auth/screens/profile_screen.dart';
import 'package:frontend/features/auth/screens/bumdes/profil_bumdes_screen.dart';

class StartPageBumdes extends StatefulWidget {
  const StartPageBumdes({super.key});

  @override
  State<StartPageBumdes> createState() => _StartPageBumdesState();
}

class _StartPageBumdesState extends State<StartPageBumdes> {
  int _page = 0;

  final List<Widget> _pages = [
    HomePageBumdes(),
    ProductPage(),
    ContactBumdesPage(),
    ProfileBumdesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      // TAMPILKAN HALAMAN SESUAI INDEX
      body: SafeArea(
        child: IndexedStack(index: _page, children: _pages),
      ),

      // BOTTOM NAV
      bottomNavigationBar: CurvedNavigationBar(
        index: _page,
        color: AppColors.primary,
        buttonBackgroundColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        animationDuration: const Duration(milliseconds: 300),

        items: [
          CurvedNavigationBarItem(
            child: Icon(
              _page == 0 ? Icons.home : Icons.home_outlined,
              color: Colors.white,
            ),
            label: _page == 0 ? 'Beranda' : '',
            labelStyle: const TextStyle(color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              _page == 1 ? Icons.receipt : Icons.receipt_outlined,
              color: Colors.white,
            ),
            label: _page == 1 ? 'Produk' : '',
            labelStyle: const TextStyle(color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              _page == 2 ? Icons.chat : Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            label: _page == 2 ? 'Pesan' : '',
            labelStyle: const TextStyle(color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              _page == 3 ? Icons.person : Icons.person_outline,
              color: Colors.white,
            ),
            label: _page == 3 ? 'Profil' : '',
            labelStyle: const TextStyle(color: Colors.white),
          ),
        ],

        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }
}
