import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/network/api_config.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isSelected;
  final bool isUpdating;
  final bool isOutOfStock;
  final ValueChanged<bool?>? onSelectionChanged;
  final Function(double) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isUpdating,
    required this.isOutOfStock,
    this.onSelectionChanged,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  String formatRupiah(int price) {
    final formatter = NumberFormat.decimalPattern("id");
    return "Rp ${formatter.format(price)}";
  }

  @override
  Widget build(BuildContext context) {
    final product = item['product'];
    final qty = double.parse(item['quantity_kg'].toString());
    final pricePerKg = double.parse(product['price_per_kg'].toString()).toInt();
    final stockKg =
        double.tryParse(product['stock_kg']?.toString() ?? '0') ?? 0;
    final imagePath =
        product['product_images'] != null &&
            (product['product_images'] as List).isNotEmpty
        ? product['product_images'][0]['image_path']
        : null;

    return Opacity(
      opacity: isOutOfStock ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOutOfStock ? AppColors.grey200 : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: AppColors.shadowLight,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isOutOfStock)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.dangerShade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'STOK HABIS',
                  style: TextStyle(
                    color: AppColors.dangerShade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              children: [
                Checkbox(
                  value: isOutOfStock ? false : isSelected,
                  activeColor: AppColors.primary,
                  onChanged: isOutOfStock ? null : onSelectionChanged,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagePath != null
                      ? Image.network(
                          ApiConfig.getImageUrl(imagePath),
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 65,
                              height: 65,
                              color: AppColors.greyLight,
                              child: const Icon(Icons.image, size: 30),
                            );
                          },
                        )
                      : Container(
                          width: 65,
                          height: 65,
                          color: AppColors.greyLight,
                          child: const Icon(Icons.image, size: 30),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Produk',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah((qty * pricePerKg).toInt()),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Harga per kg: ${formatRupiah(pricePerKg)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuantitySelector(
                              qty: qty,
                              isUpdating: isUpdating,
                              isOutOfStock: isOutOfStock,
                              stockKg: stockKg,
                              onChanged: onQuantityChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: isUpdating ? null : onRemove,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 22,
                              color: AppColors.danger,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Hapus dari keranjang',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final double qty;
  final bool isUpdating;
  final bool isOutOfStock;
  final double stockKg;
  final Function(double) onChanged;

  const _QuantitySelector({
    required this.qty,
    required this.isUpdating,
    required this.isOutOfStock,
    required this.stockKg,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cartQtyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: (isUpdating || isOutOfStock)
                ? null
                : () => onChanged(qty - 1),
            icon: const Icon(Icons.remove, size: 18),
            padding: const EdgeInsets.all(4),
          ),
          Flexible(
            child: InkWell(
              onTap: (isUpdating || isOutOfStock)
                  ? null
                  : () => _showQtyInputDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      qty.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: (isUpdating || isOutOfStock)
                          ? AppColors.grey
                          : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: (isUpdating || isOutOfStock)
                ? null
                : () => onChanged(qty + 1),
            icon: const Icon(Icons.add, size: 18),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  void _showQtyInputDialog(BuildContext context) {
    final controller = TextEditingController(text: qty.toStringAsFixed(0));
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Masukkan Jumlah (kg)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "Jumlah",
                  errorText: errorText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setDialogState(() => errorText = null);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newQty = double.tryParse(controller.text) ?? 0;
                    if (newQty <= 0) {
                      Navigator.of(context).pop();
                      return;
                    }
                    if (newQty > stockKg) {
                      setDialogState(() {
                        errorText =
                            'Jumlah melebihi stok. Stok tersedia: ${stockKg.toStringAsFixed(0)} kg';
                      });
                      return;
                    }
                    Navigator.of(context).pop();
                    onChanged(newQty);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
