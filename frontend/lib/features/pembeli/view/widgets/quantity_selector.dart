import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final double availableStock;
  final double qtyInCart;
  final bool isUpdating;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onEditTap;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.availableStock,
    this.qtyInCart = 0,
    this.isUpdating = false,
    required this.onQuantityChanged,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = quantity > 1;
    final canIncrease = availableStock > quantity;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cartQtyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            enabled: canDecrease && !isUpdating,
            onTap: () => onQuantityChanged(quantity - 1),
          ),
          GestureDetector(
            onTap: isUpdating
                ? null
                : onEditTap ?? () => _showEditDialog(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: isUpdating
                        ? AppColors.grey
                        : AppColors.primary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
            enabled: canIncrease && !isUpdating,
            onTap: () => onQuantityChanged(quantity + 1),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            "Masukkan Jumlah",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Jumlah",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text(
                "Batal",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(controller.text) ?? 1;
                final qty = input < 1 ? 1 : input;
                dialogContext.pop();
                onQuantityChanged(qty);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("OK", style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.grey400,
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryShadowMedium,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}
