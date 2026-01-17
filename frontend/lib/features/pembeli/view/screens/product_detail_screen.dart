import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/utils/date_formatter.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_bloc.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_event.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_state.dart';
import 'package:frontend/features/pembeli/view/widgets/stock_badge.dart';
import 'package:frontend/features/pembeli/view/widgets/product_detail_widgets.dart';

/// Refactored Product Detail Screen using BLoC pattern
/// Reduced from ~1038 lines to ~717 lines → Now ~150 lines after widget extraction
/// Business logic moved to ProductDetailBloc
/// Reusable widgets: QuantitySelector, StockBadge, ProductDetailWidgets
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
    return DateFormatter.formatDateFromIso(isoString);
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
        buildWhen: (previous, current) {
          // Only rebuild on these state changes to prevent unnecessary rebuilds
          return current is ProductDetailLoading ||
              current is ProductDetailLoaded ||
              current is ProductDetailError;
        },
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              body: const Center(child: AppLoadingIndicator()),
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
              ProductDetailHeader(cartItemCount: state.cartItemCount),
              const SizedBox(height: 14),
              ProductDetailImage(product: state.product),
              const SizedBox(height: 20),
              ProductDetailNameAndPrice(state: state),
              const SizedBox(height: 14),
              StockBadge(stockKg: state.stockKg),
              const SizedBox(height: 20),
              ProductDetailSellerCard(product: state.product),
              const SizedBox(height: 28),
              ProductDetailSpecificationSection(
                product: state.product,
                formatDate: formatDate,
              ),
              const SizedBox(height: 20),
              ProductDetailDescriptionSection(product: state.product),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ProductDetailBottomBar(state: state),
    );
  }
}
