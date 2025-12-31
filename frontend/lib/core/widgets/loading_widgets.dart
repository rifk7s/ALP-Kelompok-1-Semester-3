import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/core/theme/theme.dart';

/// Common loading indicators using flutter_spinkit
/// These widgets provide consistent loading states across the app

/// Primary loading indicator - Circle animation
/// Usage: Center(child: AppLoadingIndicator())
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}

/// Small inline loading indicator for buttons
/// Uses Ring animation for better button compatibility
/// Usage: AppSmallLoadingIndicator()
class AppSmallLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppSmallLoadingIndicator({
    super.key,
    this.size = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitRing(
      color: color ?? AppColors.primary,
      size: size,
      lineWidth: 2,
    );
  }
}

/// Full screen loading overlay
/// Usage: AppFullScreenLoading(message: 'Loading...')
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
            SpinKitFadingCircle(
              color: AppColors.primary,
              size: 60.0,
            ),
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
/// Usage: AppLoadingWithMessage(message: 'Please wait...')
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
          SpinKitCircle(
            color: color ?? AppColors.primary,
            size: size,
          ),
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
/// Usage: AppPulseLoadingIndicator()
class AppPulseLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppPulseLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitPulse(
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}

/// Wave loading indicator
/// Usage: AppWaveLoadingIndicator()
class AppWaveLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppWaveLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitWave(
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}

/// Ring loading indicator
/// Usage: AppRingLoadingIndicator()
class AppRingLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppRingLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitRing(
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}

/// Fading circle loading indicator
/// Usage: AppFadingCircleLoadingIndicator()
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
    return SpinKitFadingCircle(
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}
