import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom GoRouter page with smooth fade transition
/// Use this for auth routes to provide polished logout/login transitions
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({
    required super.child,
    super.key,
    super.transitionDuration = const Duration(milliseconds: 500),
    super.reverseTransitionDuration = const Duration(milliseconds: 400),
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );

            final scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.02),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}

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

/// Dramatic page route with slide from right + fade + scale
/// Creates a more noticeable transition effect
class DramaticPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  DramaticPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from right
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          // Fade in
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            ),
          );

          // Scale from slightly larger
          final scaleAnimation = Tween<double>(
            begin: 1.05,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
            ),
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
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

  /// Navigate with dramatic slide from right animation
  Future<T?> pushDramatic<T>(Widget page) {
    return Navigator.push<T>(this, DramaticPageRoute(page: page));
  }

  /// Replace with dramatic slide animation
  Future<T?> pushReplacementDramatic<T>(Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      this,
      DramaticPageRoute(page: page),
    );
  }
}
