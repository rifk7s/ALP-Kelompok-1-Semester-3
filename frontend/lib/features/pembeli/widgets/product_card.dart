import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/features/bumdes/utils/product_constants.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showSoldOutBadge;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width,
    this.height,
    this.showSoldOutBadge = true,
  });

  bool get isSoldOut => product['status'] == 'sold_out';

  @override
  Widget build(BuildContext context) {
    final stockKg = double.parse(product['stock_kg'].toString());
    final pricePerKg = double.parse(product['price_per_kg'].toString());
    final imagePath =
        product['product_images'] != null &&
            (product['product_images'] as List).isNotEmpty
        ? product['product_images'][0]['image_path']
        : null;
    final imageUrl = ApiConfig.getImageUrl(imagePath);

    return GestureDetector(
      onTap: isSoldOut ? null : onTap,
      child: Opacity(
        opacity: isSoldOut ? 0.5 : 1.0,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isSoldOut ? AppColors.greyLight : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: double.infinity,
                            color: AppColors.imagePlaceholder,
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        color: AppColors.imagePlaceholder,
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product['name']?.toString() ?? 'Produk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSoldOut
                            ? AppColors.greyDark
                            : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ProductConstants.rupiah.format(pricePerKg.toInt())}/kg',
                      style: TextStyle(
                        fontSize: 13,
                        color: isSoldOut ? AppColors.grey600 : AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Stok: ${stockKg.toStringAsFixed(0)}kg",
                      style: TextStyle(
                        fontSize: 11,
                        color: isSoldOut
                            ? AppColors.grey600
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: isSoldOut
                              ? AppColors.grey600
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Sengka, Gowa",
                            style: TextStyle(
                              fontSize: 11,
                              color: isSoldOut
                                  ? AppColors.grey600
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isSoldOut && showSoldOutBadge) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dangerShade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'STOK HABIS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dangerShade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
