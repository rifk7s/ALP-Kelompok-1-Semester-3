import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/features/shared/service/profile_service.dart';

/// Shared box container for checkout sections
class CheckoutBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const CheckoutBox({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: AppColors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Section header for checkout
class CheckoutSectionHeader extends StatelessWidget {
  final String title;

  const CheckoutSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

/// Address section displaying user profile info
class CheckoutAddressSection extends StatelessWidget {
  final Profile? userProfile;
  final bool isLoading;
  final String Function(String?) formatPhoneNumber;

  const CheckoutAddressSection({
    super.key,
    required this.userProfile,
    required this.isLoading,
    required this.formatPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: isLoading
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [AppSmallLoadingIndicator()],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.name ?? 'Pengguna',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatPhoneNumber(userProfile?.phone),
                        style: TextStyle(color: AppColors.greyDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userProfile?.address ?? 'Alamat belum diatur',
                        style: const TextStyle(height: 1.4),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Cart items list for checkout
class CheckoutCartItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> cart;

  const CheckoutCartItemsList({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: cart.map((item) => _buildCartItem(item)).toList(),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final product = item['product'];
    final imagePath = product['product_images'] != null &&
            (product['product_images'] as List).isNotEmpty
        ? product['product_images'][0]['image_path']
        : null;
    final imageUrl = ApiConfig.getImageUrl(imagePath);
    final qty = double.parse(item['quantity_kg'].toString());
    final price = double.parse(product['price_per_kg'].toString());

    return CheckoutBox(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: AppColors.greyLight,
                        child: const Icon(Icons.image, size: 30),
                      );
                    },
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: AppColors.greyLight,
                    child: const Icon(Icons.image, size: 30),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Produk',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Jumlah: x${qty.toStringAsFixed(0)}",
                  style: TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 6),
                Text(
                  "Harga: ${CurrencyFormatter.rupiah.format(price.toInt())} /kg",
                  style: TextStyle(fontSize: 13, color: AppColors.greyDark),
                ),
              ],
            ),
          ),
          Text(CurrencyFormatter.rupiah.format((qty * price).toInt())),
        ],
      ),
    );
  }
}

/// Payment method section
class CheckoutPaymentMethodSection extends StatelessWidget {
  final String paymentMethod;

  const CheckoutPaymentMethodSection({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return CheckoutBox(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Metode Pembayaran",
                  style: TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 4),
                Text(
                  paymentMethod,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shipping method section with dropdown
class CheckoutShippingSection extends StatelessWidget {
  final String shippingMethod;
  final String estimatedArrival;
  final ValueChanged<String> onShippingChanged;

  const CheckoutShippingSection({
    super.key,
    required this.shippingMethod,
    required this.estimatedArrival,
    required this.onShippingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: shippingMethod,
            decoration: InputDecoration(
              labelText: "Metode Pengiriman",
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: "Reguler",
                child: Text(
                  "Reguler - Rp ${ShippingConstants.defaultRegularShipping ~/ 1000}.000 (2–4 hari)",
                ),
              ),
              DropdownMenuItem(
                value: "Kargo",
                child: Text(
                  "Kargo - Rp ${ShippingConstants.defaultCargoShipping ~/ 1000}.000 (3–6 hari)",
                ),
              ),
              DropdownMenuItem(
                value: "Express",
                child: Text(
                  "Express - Rp ${ShippingConstants.defaultExpressShipping ~/ 1000}.000 (1 hari)",
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) onShippingChanged(value);
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.local_shipping,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Estimasi tiba: $estimatedArrival",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Payment summary section
class CheckoutPaymentSummary extends StatelessWidget {
  final int subtotal;
  final int ongkir;
  final int biayaLayanan;
  final int totalAkhir;

  const CheckoutPaymentSummary({
    super.key,
    required this.subtotal,
    required this.ongkir,
    required this.biayaLayanan,
    required this.totalAkhir,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutBox(
      child: Column(
        children: [
          _row("Subtotal", CurrencyFormatter.rupiah.format(subtotal)),
          _row("Ongkos Kirim", CurrencyFormatter.rupiah.format(ongkir)),
          _row("Biaya Layanan", CurrencyFormatter.rupiah.format(biayaLayanan)),
          const Divider(height: 26, thickness: 0.8),
          _row(
            "Total Pembayaran",
            CurrencyFormatter.rupiah.format(totalAkhir),
            bold: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notes section
class CheckoutNotesSection extends StatelessWidget {
  final TextEditingController? controller;

  const CheckoutNotesSection({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return CheckoutBox(
      child: TextField(
        controller: controller,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "Tulis catatan di sini...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// Bottom bar with total and order button
class CheckoutBottomBar extends StatelessWidget {
  final int totalAkhir;
  final bool isCreatingOrder;
  final VoidCallback onCreateOrder;

  const CheckoutBottomBar({
    super.key,
    required this.totalAkhir,
    required this.isCreatingOrder,
    required this.onCreateOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 16
            : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.06), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.rupiah.format(totalAkhir),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isCreatingOrder ? null : onCreateOrder,
              child: isCreatingOrder
                  ? const AppSmallLoadingIndicator(
                      color: AppColors.white,
                      size: 20.0,
                    )
                  : const Text(
                      "Buat Pesanan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
