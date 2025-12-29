import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/services/bumdes_service.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_bloc.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_event.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_state.dart';
import 'package:frontend/features/pembeli/widgets/quantity_selector.dart';
import 'package:frontend/features/pembeli/widgets/stock_badge.dart';

/// Refactored Product Detail Screen using BLoC pattern
/// Reduced from ~1038 lines to ~300 lines
/// Business logic moved to ProductDetailBloc
/// Reusable widgets: QuantitySelector, StockBadge
class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load fresh product data and cart count
    context.read<ProductDetailBloc>().add(
      ProductDetailLoadRequested(widget.product['id']),
    );
    context.read<ProductDetailBloc>().add(
      const ProductDetailCartCountRequested(),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductDetailBloc, ProductDetailState>(
      listener: (context, state) {
        if (state is ProductDetailError && mounted) {
          SnackBarHelper.showError(context, state.message);
        } else if (state is ProductDetailAddedToCart && mounted) {
          _showAddedToCartOverlay();
        } else if (state is ProductDetailStockValidation && mounted) {
          if (!state.isValid) {
            SnackBarHelper.showError(
              context,
              state.errorMessage ?? 'Stok tidak valid',
            );
          }
        }
      },
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProductDetailLoaded) {
            return _ProductDetailContent(state: state, formatDate: _formatDate);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddedToCartOverlay() {
    final overlayState = Overlay.of(context);
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.35,
        left: MediaQuery.of(context).size.width * 0.25,
        right: MediaQuery.of(context).size.width * 0.25,
        child: Material(
          color: AppColors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(scale: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Ditambahkan ke keranjang",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlay);
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlay.remove();
    });
  }
}

class _ProductDetailContent extends StatelessWidget {
  final ProductDetailLoaded state;
  final String Function(String) formatDate;

  const _ProductDetailContent({required this.state, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(cartItemCount: state.cartItemCount),
              const SizedBox(height: 14),
              _ProductImage(product: state.product),
              const SizedBox(height: 20),
              _ProductNameAndPrice(state: state),
              const SizedBox(height: 14),
              StockBadge(stockKg: state.stockKg),
              const SizedBox(height: 20),
              _SellerCard(product: state.product),
              const SizedBox(height: 28),
              _SpecificationSection(
                product: state.product,
                formatDate: formatDate,
              ),
              const SizedBox(height: 20),
              _DescriptionSection(product: state.product),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(state: state),
    );
  }
}

class _Header extends StatelessWidget {
  final int cartItemCount;

  const _Header({required this.cartItemCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Detail Produk",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push(RoutePaths.cart),
            ),
            if (cartItemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final imagePath =
        product['product_images'] != null &&
            (product['product_images'] as List).isNotEmpty
        ? product['product_images'][0]['image_path']
        : null;
    final imageUrl = ApiConfig.getImageUrl(imagePath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 230,
                  width: double.infinity,
                  color: AppColors.imagePlaceholder,
                  child: const Icon(
                    Icons.image,
                    size: 80,
                    color: AppColors.textMuted,
                  ),
                );
              },
            )
          : Container(
              height: 230,
              width: double.infinity,
              color: AppColors.imagePlaceholder,
              child: const Icon(
                Icons.image,
                size: 80,
                color: AppColors.textMuted,
              ),
            ),
    );
  }
}

class _ProductNameAndPrice extends StatelessWidget {
  final ProductDetailLoaded state;

  const _ProductNameAndPrice({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.product['name']?.toString() ?? 'Produk',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Rp ${state.parsedPrice.toString()}/kg',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _SellerCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _SellerCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primaryShadow, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/images/logo.png"),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("BUMDes", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "Sengka, Gowa",
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openChat(context),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context) async {
    final bumdes = await BumdesService.getBumdesInfo();
    if (!context.mounted || bumdes == null) return;

    final chatId = await ChatService.getOrCreateChat(
      recipientId: bumdes.id,
      recipientName: bumdes.name,
      recipientImage: 'assets/images/logo.png',
    );

    if (!context.mounted || chatId == null) return;

    await context.push(
      RoutePaths.chat.replaceAll(':id', chatId),
      extra: {
        'chatId': chatId,
        'name': bumdes.name,
        'image': 'assets/images/logo.png',
        'recipientId': bumdes.id.toString(),
      },
    );
  }
}

class _SpecificationSection extends StatelessWidget {
  final Map<String, dynamic> product;
  final String Function(String) formatDate;

  const _SpecificationSection({
    required this.product,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primaryShadow, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spesifikasi Produk",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.category_outlined,
            label: "Kategori",
            value: product['category']?['name'] ?? '-',
          ),
          _InfoRow(
            icon: Icons.qr_code_2_outlined,
            label: "Varietas",
            value: product['variety'] ?? '-',
          ),
          _InfoRow(
            icon: Icons.date_range_outlined,
            label: "Tanggal Panen",
            value: formatDate(product['harvest_date']),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final Map<String, dynamic> product;

  const _DescriptionSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primaryShadow, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Info Tambahan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Text(
              product['description'] ?? 'Tidak ada informasi tambahan.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ProductDetailLoaded state;

  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: state.availableStock > 0
                  ? () => _openQtyDialog(context)
                  : () {
                      SnackBarHelper.showError(
                        context,
                        state.qtyInCart > 0
                            ? 'Stok tidak cukup. Anda sudah memiliki ${state.qtyInCart.toInt()} kg di keranjang dan stok tersisa ${state.availableStock.toInt()} kg'
                            : 'Stok habis',
                      );
                    },
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text(
                'Keranjang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openQtyDialog(BuildContext context) {
    DialogManager.show(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<ProductDetailBloc>(),
          child: _QtyDialogContent(state: state),
        );
      },
    );
  }
}

class _QtyDialogContent extends StatefulWidget {
  final ProductDetailLoaded state;

  const _QtyDialogContent({required this.state});

  @override
  State<_QtyDialogContent> createState() => _QtyDialogContentState();
}

class _QtyDialogContentState extends State<_QtyDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, blocState) {
            if (blocState is! ProductDetailLoaded) {
              return const SizedBox.shrink();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  blocState.product['name'] ?? 'Produk',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _ProductImage(product: blocState.product),
                ),
                const SizedBox(height: 18),
                QuantitySelector(
                  quantity: blocState.selectedQty,
                  availableStock: blocState.availableStock,
                  qtyInCart: blocState.qtyInCart,
                  onQuantityChanged: (qty) {
                    context.read<ProductDetailBloc>().add(
                      ProductDetailQuantityChanged(qty),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Total: Rp ${blocState.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<ProductDetailBloc>().add(
                            ProductDetailAddToCartRequested(
                              productId: blocState.product['id'],
                              quantityKg: blocState.selectedQty.toDouble(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Tambah",
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
