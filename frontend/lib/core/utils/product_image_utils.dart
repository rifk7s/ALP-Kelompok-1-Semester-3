class ProductImageUtils {
  static String? firstImagePath(Map<String, dynamic>? product) {
    if (product == null) return null;

    // Common backend shape: product_images: [{ image_path: "storage/..." }]
    final images = product['product_images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        final dynamic imagePath =
            first['image_path'] ?? first['image'] ?? first['image_url'];
        final asString = imagePath?.toString();
        if (asString != null && asString.isNotEmpty) return asString;
      }
    }

    // Fallbacks seen across some UI code paths
    final direct =
        product['image_path'] ?? product['image'] ?? product['image_url'];
    final asString = direct?.toString();
    if (asString != null && asString.isNotEmpty) return asString;

    return null;
  }
}
