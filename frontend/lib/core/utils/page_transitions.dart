import 'package:flutter/material.dart';

/// Custom page route with smooth staggered animation
/// Combines fade, scale, and slide transitions for a polished effect
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            ),
          );

          final scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
            ),
          );

          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0.0, 0.03),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
                ),
              );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: SlideTransition(position: slideAnimation, child: child),
            ),
          );
        },
      );
}

/// Extension for easy navigation with smooth transitions
extension SmoothNavigation on BuildContext {
  /// Navigate to a page with smooth animation
  Future<T?> pushSmooth<T>(Widget page) {
    return Navigator.push<T>(this, SmoothPageRoute(page: page));
  }

  /// Replace current page with smooth animation
  Future<T?> pushReplacementSmooth<T>(Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      this,
      SmoothPageRoute(page: page),
    );
  }

  /// Navigate and remove all previous routes with smooth animation
  Future<T?> pushAndRemoveAllSmooth<T>(Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      SmoothPageRoute(page: page),
      (route) => false,
    );
  }
}
