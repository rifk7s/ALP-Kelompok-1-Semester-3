import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/shared/service/profile_service.dart';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/features/pembeli/service/order_service.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/features/pembeli/view/widgets/transaction/checkout_widgets.dart';

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

  String paymentMethod = "Transfer Bank (${PaymentConstants.defaultBank})";
  int ongkir = ShippingConstants.defaultRegularShipping;
  int biayaLayanan = ShippingConstants.serviceFee;
  String shippingMethod = "Reguler";
  String estimatedArrival = "2–4 hari";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoadingProfile = true);
    try {
      final token = await StorageService.getToken();

      // Minimum delay for UX - ensures spinner is visible
      final profileFuture = ProfileService().fetchProfile(token: token);
      final delayFuture = Future.delayed(LoadingDelayConstants.standardList);

      final profile = await profileFuture;
      await delayFuture;

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
    if (phone.length >= 4) {
      return '${phone.substring(0, 4)}-${phone.substring(4)}';
    }
    return phone;
  }

  void _onShippingChanged(String value) {
    setState(() {
      shippingMethod = value;
      switch (value) {
        case "Reguler":
          ongkir = ShippingConstants.defaultRegularShipping;
          estimatedArrival = "2–4 hari";
          break;
        case "Kargo":
          ongkir = ShippingConstants.defaultCargoShipping;
          estimatedArrival = "3–6 hari";
          break;
        case "Express":
          ongkir = ShippingConstants.defaultExpressShipping;
          estimatedArrival = "1 hari";
          break;
      }
    });
  }

  Future<void> _createOrder() async {
    if (kDebugMode) debugPrint('_createOrder called');
    if (isCreatingOrder) {
      if (kDebugMode) debugPrint('Already creating order, returning');
      return;
    }

    setState(() => isCreatingOrder = true);
    if (kDebugMode) debugPrint('Creating order started');

    showLoadingDialog(context, message: 'Memproses pesanan...');

    try {
      if (kDebugMode) debugPrint('Calling OrderService.createOrder...');

      final results = await Future.wait([
        OrderService.createOrder(
          shippingAddress: userProfile?.address,
          shippingCost: ongkir,
          serviceFee: biayaLayanan,
        ),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);

      final order = results[0] as Map<String, dynamic>?;
      if (kDebugMode) debugPrint('Order result: $order');

      if (!mounted) return;
      Navigator.of(context).pop();

      if (order != null) {
        if (kDebugMode) debugPrint('Order created successfully, navigating...');
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
                const CheckoutSectionHeader("Alamat Pengiriman"),
                CheckoutAddressSection(
                  userProfile: userProfile,
                  isLoading: isLoadingProfile,
                  formatPhoneNumber: _formatPhoneNumber,
                ),
                const SizedBox(height: 20),

                const CheckoutSectionHeader("Produk Dipesan"),
                CheckoutCartItemsList(cart: widget.cart),
                const SizedBox(height: 20),

                const CheckoutSectionHeader("Metode Pembayaran"),
                CheckoutPaymentMethodSection(paymentMethod: paymentMethod),
                const SizedBox(height: 20),

                const CheckoutSectionHeader("Pengiriman"),
                CheckoutShippingSection(
                  shippingMethod: shippingMethod,
                  estimatedArrival: estimatedArrival,
                  onShippingChanged: _onShippingChanged,
                ),
                const SizedBox(height: 20),

                const CheckoutSectionHeader("Rincian Pembayaran"),
                CheckoutPaymentSummary(
                  subtotal: subtotal,
                  ongkir: ongkir,
                  biayaLayanan: biayaLayanan,
                  totalAkhir: totalAkhir,
                ),
                const SizedBox(height: 20),

                const CheckoutSectionHeader("Catatan untuk Penjual (Opsional)"),
                const CheckoutNotesSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          CheckoutBottomBar(
            totalAkhir: totalAkhir,
            isCreatingOrder: isCreatingOrder,
            onCreateOrder: _createOrder,
          ),
        ],
      ),
    );
  }
}
