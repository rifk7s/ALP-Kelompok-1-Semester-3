import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/product_image_utils.dart';
import 'package:frontend/features/pembeli/widgets/transaction/transaction_card_widgets.dart';

/// Widget for displaying order products list
class OrderProductsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> order;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onProductTap;

  const OrderProductsWidget({
    super.key,
    required this.products,
    required this.order,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First product with "Lihat Detail" link
          InkWell(
            onTap: onProductTap,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImageWidget(
                    imagePath: products[0]['image'] as String?,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        products[0]['name']?.toString() ?? 'Produk',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${products[0]['qty'] ?? 0} kg',
                        style: TextStyle(fontSize: 12, color: AppColors.grey600),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.grey600,
                  size: 24,
                ),
              ],
            ),
          ),

          // Expandable section for additional products
          if (products.length > 1) ...[
            const SizedBox(height: 12),

            // Show expanded products if order is expanded
            if (isExpanded)
              ...products.skip(1).map((product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ProductImageWidget(
                            imagePath: product['image'] as String?,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name']?.toString() ?? 'Produk',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product['qty'] ?? 0} kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

            // "Lihat Semua" button
            InkWell(
              onTap: onToggleExpand,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded
                          ? 'Sembunyikan'
                          : 'Lihat Semua (${products.length - 1} produk lainnya)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Parse order items from backend format to products list
List<Map<String, dynamic>> parseOrderItems(dynamic orderItems) {
  final items = orderItems as List? ?? [];
  
  return items.map((item) {
    if (item is Map<String, dynamic> && item['product'] != null) {
      // Backend format
      final product = item['product'] as Map<String, dynamic>?;
      final imagePath = ProductImageUtils.firstImagePath(product);
      return {
        'name': product?['name']?.toString() ?? 'Produk',
        'qty': double.parse(item['quantity_kg']?.toString() ?? '0').toInt(),
        'image': imagePath,
      };
    }
    // Dummy format
    return {
      'name': item['name']?.toString() ?? 'Produk',
      'qty': item['qty'] ?? 0,
      'image': item['image']?.toString(),
    };
  }).toList();
}
