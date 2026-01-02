import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/core/services/profile_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/core/services/order_service.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int total;

  const CheckoutPage({super.key, required this.cart, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Profile? userProfile;
  bool isLoadingProfile = true;
  bool isCreatingOrder = false;

  String paymentMethod = "Transfer Bank (BCA)";
  int ongkir = 15000;
  int biayaLayanan = 2500;
  String shippingMethod = "Reguler";
  String estimatedArrival = "2–4 hari";

  final NumberFormat rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoadingProfile = true);
    try {
      final token = await StorageService.getToken();
      final profile = await ProfileService().fetchProfile(token: token);
      setState(() {
        userProfile = profile;
        isLoadingProfile = false;
      });
    } catch (e) {
      setState(() => isLoadingProfile = false);
    }
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    // Format: 0812-3456-7890
    if (phone.length >= 4) {
      return '${phone.substring(0, 4)}-${phone.substring(4)}';
    }
    return phone;
  }

  Future<void> _createOrder() async {
    if (kDebugMode) {
      debugPrint('_createOrder called');
    }
    if (isCreatingOrder) {
      if (kDebugMode) {
        debugPrint('Already creating order, returning');
      }
      return;
    }

    setState(() => isCreatingOrder = true);
    if (kDebugMode) {
      debugPrint('Creating order started');
    }

    // Show loading dialog
    showLoadingDialog(context, message: 'Memproses pesanan...');

    try {
      if (kDebugMode) {
        debugPrint('Calling OrderService.createOrder...');
      }
      
      // Run order creation and minimum delay in parallel
      final results = await Future.wait([
        OrderService.createOrder(
          shippingAddress: userProfile?.address,
          shippingCost: ongkir,
          serviceFee: biayaLayanan,
        ),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);
      
      final order = results[0] as Map<String, dynamic>?;

      if (kDebugMode) {
        debugPrint('Order result: $order');
      }

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (order != null) {
        if (kDebugMode) {
          debugPrint('Order created successfully, navigating...');
        }
        // Navigate to waiting payment screen
        context.replace(
          RoutePaths.paymentWaiting,
          extra: {
            'order_id': order['id'] as int?,
            'order_number': order['order_number'] ?? '',
            'total': (order['total'] is int)
                ? order['total']
                : int.tryParse(order['total']?.toString() ?? '0'),
          },
        );
      } else if (mounted) {
        SnackBarHelper.showError(context, 'Gagal membuat pesanan');
        setState(() => isCreatingOrder = false);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Terjadi kesalahan');
        setState(() => isCreatingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int subtotal = widget.cart.fold(0, (t, item) {
      final qty = double.parse(item['quantity_kg'].toString());
      final price = double.parse(item['product']['price_per_kg'].toString());
      return t + (qty * price).toInt();
    });

    int totalAkhir = subtotal + ongkir + biayaLayanan;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionHeader("Alamat Pengiriman"),

                _box(
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
                        child: isLoadingProfile
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
                                    _formatPhoneNumber(userProfile?.phone),
                                    style: TextStyle(color: AppColors.greyDark),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    userProfile?.address ??
                                        'Alamat belum diatur',
                                    style: const TextStyle(height: 1.4),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Produk Dipesan"),

                ...widget.cart.map(
                  (item) => _box(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: () {
                            final product = item['product'];
                            final imagePath =
                                product['product_images'] != null &&
                                    (product['product_images'] as List)
                                        .isNotEmpty
                                ? product['product_images'][0]['image_path']
                                : null;
                            final imageUrl = ApiConfig.getImageUrl(imagePath);

                            return imageUrl.isNotEmpty
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
                                        child: const Icon(
                                          Icons.image,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 70,
                                    height: 70,
                                    color: AppColors.greyLight,
                                    child: const Icon(Icons.image, size: 30),
                                  );
                          }(),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product']['name'] ?? 'Produk',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Jumlah: x${double.parse(item['quantity_kg'].toString()).toStringAsFixed(0)}",
                                style: TextStyle(color: AppColors.grey600),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Harga: ${rupiah.format(double.parse(item['product']['price_per_kg'].toString()).toInt())} /kg",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.greyDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          rupiah.format(
                            (double.parse(item['quantity_kg'].toString()) *
                                    double.parse(
                                      item['product']['price_per_kg']
                                          .toString(),
                                    ))
                                .toInt(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Metode Pembayaran"),

                _box(
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
                ),

                const SizedBox(height: 20),

                _sectionHeader("Pengiriman"),

                _box(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: shippingMethod,
                        decoration: InputDecoration(
                          labelText: "Metode Pengiriman",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Reguler",
                            child: Text("Reguler - Rp 15.000 (2–4 hari)"),
                          ),
                          DropdownMenuItem(
                            value: "Kargo",
                            child: Text("Kargo - Rp 8.000 (3–6 hari)"),
                          ),
                          DropdownMenuItem(
                            value: "Express",
                            child: Text("Express - Rp 25.000 (1 hari)"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            shippingMethod = value!;

                            if (value == "Reguler") {
                              ongkir = 15000;
                              estimatedArrival = "2–4 hari";
                            } else if (value == "Kargo") {
                              ongkir = 8000;
                              estimatedArrival = "3–6 hari";
                            } else if (value == "Express") {
                              ongkir = 25000;
                              estimatedArrival = "1 hari";
                            }
                          });
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
                ),

                const SizedBox(height: 20),

                _sectionHeader("Rincian Pembayaran"),

                _box(
                  child: Column(
                    children: [
                      _row("Subtotal", rupiah.format(subtotal)),
                      _row("Ongkos Kirim", rupiah.format(ongkir)),
                      _row("Biaya Layanan", rupiah.format(biayaLayanan)),
                      const Divider(height: 26, thickness: 0.8),
                      _row(
                        "Total Pembayaran",
                        rupiah.format(totalAkhir),
                        bold: true,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Catatan untuk Penjual (Opsional)"),

                _box(
                  child: TextField(
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: "Tulis catatan di sini...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          Container(
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
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rupiah.format(totalAkhir),
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
                    onPressed: isCreatingOrder ? null : _createOrder,
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
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
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

  Widget _box({required Widget child, EdgeInsetsGeometry? margin}) {
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
