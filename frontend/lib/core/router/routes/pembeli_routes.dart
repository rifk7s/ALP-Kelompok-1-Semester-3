import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:frontend/features/pembeli/screens/home_screen.dart';
import 'package:frontend/features/pembeli/screens/profile_screen.dart';
import 'package:frontend/features/shared/screens/contact_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/transaction_history_screen.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/theme/theme.dart';

/// Pembeli (Buyer) feature routes using ShellRoute for bottom navigation
class PembeliRoutes {
  static RouteBase pembeliShellRoute = ShellRoute(
    builder: (context, state, child) {
      return _PembeliNavigationWrapper(child: child);
    },
    routes: [
      GoRoute(
        path: RoutePaths.pembeliHome,
        name: RouteNames.pembeliHome,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

/// Navigation wrapper for Pembeli - maintains bottom navigation
class _PembeliNavigationWrapper extends StatefulWidget {
  final Widget child;

  const _PembeliNavigationWrapper({required this.child});

  @override
  State<_PembeliNavigationWrapper> createState() =>
      _PembeliNavigationWrapperState();
}

class _PembeliNavigationWrapperState extends State<_PembeliNavigationWrapper> {
  int _currentIndex = 0;

  // Store all pages for IndexedStack to maintain state
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      widget.child, // This will be HomePage when navigated to /pembeli
      const TransactionHistoryPage(),
      const ContactPage(),
      const ProfilePage(),
    ];
  }

  @override
  void didUpdateWidget(_PembeliNavigationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update HomePage when child changes
    if (oldWidget.child != widget.child) {
      _pages[0] = widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return CurvedNavigationBar(
      index: _currentIndex,
      color: AppColors.primary,
      buttonBackgroundColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        CurvedNavigationBarItem(
          child: Icon(
            _currentIndex == 0 ? Icons.home : Icons.home_outlined,
            color: AppColors.white,
          ),
          label: _currentIndex == 0 ? 'Beranda' : '',
          labelStyle: const TextStyle(color: AppColors.white),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            _currentIndex == 1 ? Icons.receipt : Icons.receipt_outlined,
            color: AppColors.white,
          ),
          label: _currentIndex == 1 ? 'Transaksi' : '',
          labelStyle: const TextStyle(color: AppColors.white),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            _currentIndex == 2 ? Icons.chat : Icons.chat_bubble_outline,
            color: AppColors.white,
          ),
          label: _currentIndex == 2 ? 'Pesan' : '',
          labelStyle: const TextStyle(color: AppColors.white),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            _currentIndex == 3 ? Icons.person : Icons.person_outline,
            color: AppColors.white,
          ),
          label: _currentIndex == 3 ? 'Profil' : '',
          labelStyle: const TextStyle(color: AppColors.white),
        ),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
