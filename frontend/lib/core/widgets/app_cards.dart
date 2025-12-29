import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

/// REUSABLE CARD COMPONENTS
/// Matches homepage aesthetic: rounded corners, soft shadows, generous spacing
class AppCards {
  /// Standard product card - matches homepage product grid
  static Widget productCard({
    required Widget child,
    VoidCallback? onTap,
    bool isSoldOut = false,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isSoldOut ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isSoldOut ? AppColors.greyLight : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Cart item card - elevated with more shadow
  static Widget cartItem({
    required Widget child,
    VoidCallback? onLongPress,
    bool isSelected = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.shadowLight,
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: child,
    );
  }

  /// Profile section card - subtle, minimal
  static Widget profileSection({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  /// Action button card - for menus/settings
  static Widget actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Simple action button - matches bumdes profile aesthetic with card background
  static Widget actionButtonSimple({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textLight, size: 24),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing:
            trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
        onTap: onTap,
      ),
    );
  }
}

/// SPACING CONSTANTS - matches homepage
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Page padding
  static const pageHorizontal = 20.0;
  static const pageVertical = 20.0;

  // Card spacing
  static const cardMargin = 12.0;
  static const cardPadding = 16.0;

  // Grid spacing
  static const gridSpacing = 12.0;
}

/// BORDER RADIUS CONSTANTS
class AppBorderRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 25;
  static const double full = 40;
}
