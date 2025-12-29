import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class StockBadge extends StatelessWidget {
  final double stockKg;

  const StockBadge({super.key, required this.stockKg});

  bool get isInStock => stockKg > 0;
  bool get isLowStock => stockKg > 0 && stockKg < 10;

  @override
  Widget build(BuildContext context) {
    if (!isInStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Stok Habis",
          style: TextStyle(color: AppColors.white, fontSize: 12),
        ),
      );
    }

    if (isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "Tersedia: ${stockKg.toStringAsFixed(0)}kg",
          style: const TextStyle(color: AppColors.white, fontSize: 12),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Tersedia: ${stockKg.toStringAsFixed(0)}kg",
        style: const TextStyle(color: AppColors.white, fontSize: 12),
      ),
    );
  }
}
