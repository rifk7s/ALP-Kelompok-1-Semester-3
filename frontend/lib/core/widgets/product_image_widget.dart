import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/network/api_config.dart';

/// Reusable product image widget with consistent error handling
/// Used across pembeli, bumdes, and shared features
class ProductImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final String? placeholderText;

  const ProductImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderText,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.getImageUrl(imagePath);
    final hasImage = imageUrl.isNotEmpty && imageUrl != 'https://via.placeholder.com/150';

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: hasImage
          ? Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.imagePlaceholder,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image,
              color: AppColors.textMuted,
              size: 32,
            ),
            if (placeholderText != null) ...[
              const SizedBox(height: 8),
              Text(
                placeholderText!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
