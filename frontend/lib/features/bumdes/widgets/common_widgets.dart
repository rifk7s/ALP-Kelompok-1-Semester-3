import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/core/theme/theme.dart';

/// Common UI widgets used across bumdes screens
/// Extracted to reduce code duplication

/// Section card widget with title and content
/// Used to group related form fields
class BumdesSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BumdesSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Input label widget for form fields
/// Provides consistent styling for field labels
class BumdesInputLabel extends StatelessWidget {
  final String text;
  final bool required;

  const BumdesInputLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty state widget for lists
class BumdesEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const BumdesEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading indicator widget with spinkit animation
class BumdesLoadingIndicator extends StatelessWidget {
  final String? message;

  const BumdesLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCircle(
            color: AppColors.primary,
            size: 50.0,
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

/// Small loading indicator for buttons and inline loading
class BumdesSmallLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const BumdesSmallLoadingIndicator({
    super.key,
    this.color,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}

/// Full screen loading overlay with primary theme color
class BumdesFullScreenLoading extends StatelessWidget {
  final String? message;

  const BumdesFullScreenLoading({super.key, this.message});

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

/// Loading indicator with pulse animation
class BumdesPulseLoadingIndicator extends StatelessWidget {
  final String? message;

  const BumdesPulseLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitPulse(
            color: AppColors.primary,
            size: 50.0,
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
