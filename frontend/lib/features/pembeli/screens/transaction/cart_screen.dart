import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/pembeli/bloc/cart/cart_bloc.dart';
import 'package:frontend/features/pembeli/bloc/cart/cart_event.dart';
import 'package:frontend/features/pembeli/bloc/cart/cart_state.dart';
import 'package:frontend/features/pembeli/widgets/product_card.dart';
import 'package:frontend/features/pembeli/widgets/cart_item_card.dart';

/// Refactored Cart Screen using BLoC pattern
/// Reduced from ~983 lines to ~220 lines
/// Business logic is now in CartBloc
/// Reusable widgets extracted: ProductCard, CartItemCard
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final formatter = NumberFormat.decimalPattern("id");

  @override
  void initState() {
    super.initState();
    // Load cart and recommendations when screen initializes
    context.read<CartBloc>().add(const CartLoadRequested());
    context.read<CartBloc>().add(const CartRecommendationsLoadRequested());
  }

  String formatRupiah(int price) => "Rp ${formatter.format(price)}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Keranjang",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          // Handle error states
          if (state is CartError && mounted) {
            SnackBarHelper.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CartLoading && state.showSpinner) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartLoaded) {
            if (state.cartItems.isEmpty) {
              return const _EmptyCartWidget();
            }

            return _CartContent(
              state: state,
              formatter: formatter,
              formatRupiah: formatRupiah,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final CartLoaded state;
  final NumberFormat formatter;
  final String Function(int) formatRupiah;

  const _CartContent({
    required this.state,
    required this.formatter,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cart Items List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cartItems.length,
                  itemBuilder: (context, i) {
                    final item = state.cartItems[i];
                    final product = item['product'];
                    final stockKg =
                        double.tryParse(
                          product['stock_kg']?.toString() ?? '0',
                        ) ??
                        0;
                    final isSelected = state.selectedItems[item['id']] ?? false;
                    final isUpdating = state.updatingItems.contains(item['id']);

                    return CartItemCard(
                      item: item,
                      isSelected: isSelected,
                      isUpdating: isUpdating,
                      isOutOfStock: stockKg <= 0,
                      onSelectionChanged: (value) {
                        context.read<CartBloc>().add(
                          CartItemSelectedToggled(
                            itemId: item['id'],
                            isSelected: value ?? false,
                          ),
                        );
                      },
                      onQuantityChanged: (newQty) {
                        context.read<CartBloc>().add(
                          CartItemQuantityChanged(item: item, newQty: newQty),
                        );
                      },
                      onRemove: () {
                        context.read<CartBloc>().add(
                          CartItemRemoved(item['id']),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Recommendations Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rekomendasi Produk",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.recommendations.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.74,
                  ),
                  itemBuilder: (context, i) {
                    final product = state.recommendations[i];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        context.push(
                          RoutePaths.productDetail.replaceAll(
                            ':id',
                            '${product['id']}',
                          ),
                          extra: product,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 130),
              ],
            ),
          ),
        ),

        // Bottom Sheet with Total and Checkout Button
        _CartBottomSheet(state: state, formatRupiah: formatRupiah),
      ],
    );
  }
}

class _CartBottomSheet extends StatelessWidget {
  final CartLoaded state;
  final String Function(int) formatRupiah;

  const _CartBottomSheet({required this.state, required this.formatRupiah});

  void _handleCheckout(BuildContext context) async {
    if (state.totalSelectedItems == 0) return;

    final selectedCart = state.cartItems
        .where((item) => state.selectedItems[item['id']] == true)
        .toList();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Validate stock
    context.read<CartBloc>().add(CartStockValidated(selectedCart));

    // Wait a bit for validation to complete
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) return;

    // Close loading
    Navigator.of(context).pop();

    // Navigate to checkout
    context.push(
      RoutePaths.checkout,
      extra: {'cart': selectedCart, 'total': state.totalPrice},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Select All Row
          Row(
            children: [
              Checkbox(
                value: state.selectAll,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  context.read<CartBloc>().add(
                    CartSelectAllToggled(value ?? false),
                  );
                },
              ),
              const Text("Pilih Semua"),
              const Spacer(),
              Text(
                "${state.totalSelectedItems} item dipilih",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Total and Checkout Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Pembayaran",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatRupiah(state.totalPrice),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: state.totalSelectedItems == 0
                      ? null
                      : () => _handleCheckout(context),
                  child: const Text(
                    "Buat Pesanan",
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCartWidget extends StatelessWidget {
  const _EmptyCartWidget();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Text(
          "Keranjang masih kosong",
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
