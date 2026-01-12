import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/core/theme/theme.dart';

/// Common loading indicators using flutter_spinkit
/// These widgets provide consistent loading states across the app
///
/// USAGE GUIDE BY CONTEXT:
/// - Button loading: AppSmallLoadingIndicator (Ring - compact, clean)
/// - Page/Content loading: AppLoadingIndicator (Circle - classic, reliable)
/// - Full screen overlay: AppFullScreenLoading (FadingCircle - elegant)
/// - Chat/Messaging: AppDotsLoadingIndicator (ThreeBounce - typing feel)
/// - Payment/Transaction: AppPulseLoadingIndicator (Pulse - attention)
/// - Data sync/Refresh: AppRippleLoadingIndicator (Ripple - refreshing feel)
/// - Form submission: AppDualRingLoadingIndicator (DualRing - processing)
/// - Image loading: AppFadingCircleLoadingIndicator (FadingCircle - smooth)

/// Primary loading indicator - Circle animation
/// Best for: General page loading, content loading
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(color: color ?? AppColors.primary, size: size);
  }
}

/// Small inline loading indicator for buttons
/// Best for: Button loading states, inline actions
class AppSmallLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppSmallLoadingIndicator({super.key, this.size = 20.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitRing(
      color: color ?? AppColors.primary,
      size: size,
      lineWidth: 2,
    );
  }
}

/// Three bouncing dots indicator
/// Best for: Chat/messaging, typing indicators, subtle loading
class AppDotsLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppDotsLoadingIndicator({super.key, this.size = 30.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color ?? AppColors.primary,
      size: size / 2,
    );
  }
}

/// Ripple effect loading indicator
/// Best for: Refresh actions, data sync, search loading
class AppRippleLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppRippleLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitRipple(color: color ?? AppColors.primary, size: size);
  }
}

/// Dual ring loading indicator
/// Best for: Form submission, data processing, upload/download
class AppDualRingLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppDualRingLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitDualRing(
      color: color ?? AppColors.primary,
      size: size,
      lineWidth: 3,
    );
  }
}

/// Full screen loading overlay
/// Best for: Initial app loading, major transitions
class AppFullScreenLoading extends StatelessWidget {
  final String? message;

  const AppFullScreenLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCircle(color: AppColors.primary, size: 60.0),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator with optional message
/// Best for: Page loading with context message
class AppLoadingWithMessage extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoadingWithMessage({
    super.key,
    this.message,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCircle(color: color ?? AppColors.primary, size: size),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pulse style loading indicator
/// Best for: Payment processing, attention-grabbing loading
class AppPulseLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppPulseLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitPulse(color: color ?? AppColors.primary, size: size);
  }
}

/// Wave loading indicator
/// Best for: Audio/media loading, horizontal layouts
class AppWaveLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppWaveLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitWave(color: color ?? AppColors.primary, size: size);
  }
}

/// Ring loading indicator
/// Best for: Simple inline loading, compact spaces
class AppRingLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppRingLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitRing(color: color ?? AppColors.primary, size: size);
  }
}

/// Fading circle loading indicator
/// Best for: Image loading, elegant transitions, profile loading
class AppFadingCircleLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppFadingCircleLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(color: color ?? AppColors.primary, size: size);
  }
}

/// Chasing dots loading indicator
/// Best for: Playful loading, search operations
class AppChasingDotsLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppChasingDotsLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitChasingDots(color: color ?? AppColors.primary, size: size);
  }
}

/// Spinning circle loading indicator
/// Best for: 3D feel, product loading, modern UI
class AppSpinningCircleLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppSpinningCircleLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitSpinningCircle(color: color ?? AppColors.primary, size: size);
  }
}

/// Cube grid loading indicator
/// Best for: Grid/list loading, product catalog, data tables
class AppCubeGridLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppCubeGridLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitCubeGrid(color: color ?? AppColors.primary, size: size);
  }
}

/// Shows a loading dialog overlay with customizable appearance
/// Use this for action dialogs that need visible loading state
///
/// [message] - Optional text to show below spinner (e.g., "Memproses pesanan...")
/// [backgroundColor] - Dialog card background (default: cream/surface)
void showLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.black.withValues(alpha: 0.6),
    builder: (context) => Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: message != null ? 24 : 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppFadingCircleLoadingIndicator(size: 45),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Full screen loading with scaffold
/// Best for: Page-level loading states with scaffold wrapper
class AppLoadingScreen extends StatelessWidget {
  final String? message;

  const AppLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoadingIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
