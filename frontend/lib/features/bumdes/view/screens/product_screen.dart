import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/bumdes/bloc/product_list/product_list_bloc.dart';
import 'package:frontend/features/bumdes/bloc/product_list/product_list_event.dart';
import 'package:frontend/features/bumdes/bloc/product_list/product_list_state.dart';
import 'package:frontend/features/product/repository/product_repository.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductListBloc(
        productRepository: sl<ProductRepository>(),
      )..add(const ProductListLoadRequested()),
      child: const _ProductPageContent(),
    );
  }
}

class _ProductPageContent extends StatelessWidget {
  const _ProductPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return RetryableContent(
            isLoading: state.isLoading,
            hasError: state.hasError,
            errorMessage: state.errorMessage,
            onRetry: () => context
                .read<ProductListBloc>()
                .add(const ProductListLoadRequested()),
            child: PullToRefresh(
              onRefresh: () async {
                context.read<ProductListBloc>().add(
                      const ProductListLoadRequested(
                        showSpinner: false,
                        forceRefresh: true,
                      ),
                    );
              },
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              displacement: 40,
              strokeWidth: 2.5,
              child: SafeArea(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _Header()),
                    SliverToBoxAdapter(child: _FilterChips()),
                    state.filteredProducts.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: _emptyState(),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = state.filteredProducts[index];
                                  return _ProductCard(product: product);
                                },
                                childCount: state.filteredProducts.length,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addProdukFab",
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () async {
          final result = await context.pushNamed(RouteNames.productUpload);
          if (result == true && context.mounted) {
            context.read<ProductListBloc>().add(
                  const ProductListLoadRequested(
                    showSpinner: false,
                    forceRefresh: true,
                  ),
                );
          }
        },
        child: const Icon(Icons.add, size: 28, color: AppColors.white),
      ),
    );
  }

  Widget _emptyState() {
    return const EmptyStateWidget(
      message: 'Tidak ada produk',
      icon: Icons.inventory_2_outlined,
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              const Center(
                child: Text(
                  "Produk Saya",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    context.pushNamed('notifications');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: "Cari produk...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              context
                  .read<ProductListBloc>()
                  .add(ProductListSearchChanged(value));
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      buildWhen: (prev, curr) => prev.filter != curr.filter,
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFilterChip(context, state.filter, "all", "Semua"),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    state.filter,
                    "available",
                    "Stok Tersedia",
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    state.filter,
                    "empty",
                    "Stok Habis",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String currentFilter,
    String key,
    String label,
  ) {
    final selected = currentFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => context
          .read<ProductListBloc>()
          .add(ProductListFilterChanged(key)),
      selectedColor: AppColors.primaryLight,
      backgroundColor: AppColors.white,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isSoldOut = product['status'] == 'sold_out';
    final stockKg = double.parse(product['stock_kg'].toString());
    final pricePerKg = double.parse(product['price_per_kg'].toString());
    final imagePath = product['product_images'] != null &&
            (product['product_images'] as List).isNotEmpty
        ? product['product_images'][0]['image_path']
        : null;
    final imageUrl = ApiConfig.getImageUrl(imagePath);

    // Get number of contributors
    int contributorCount = 0;
    if (product['product_contributions'] != null) {
      contributorCount = (product['product_contributions'] as List).length;
    }

    return GestureDetector(
      onTap: () async {
        await context.push(
          RoutePaths.productDetail.replaceAll(':id', '${product['id']}'),
          extra: {
            ...product,
            'isBumdes': true,
          },
        );

        // Reload products after returning from detail screen
        if (context.mounted) {
          context.read<ProductListBloc>().add(
                const ProductListLoadRequested(
                  showSpinner: false,
                  forceRefresh: true,
                ),
              );
        }
      },
      child: Opacity(
        opacity: isSoldOut ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isSoldOut ? AppColors.greyLight : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.imagePlaceholder,
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? const Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.textMuted,
                        )
                      : null,
                ),
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSoldOut
                            ? AppColors.greyDark
                            : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Stock • Price
                    Row(
                      children: [
                        Text(
                          "${stockKg.toStringAsFixed(0)} kg",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSoldOut
                                ? AppColors.grey600
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          " • ",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSoldOut
                                ? AppColors.grey600
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.rupiah.format(pricePerKg.toInt()),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSoldOut
                                ? AppColors.grey600
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Number of contributors
                    Text(
                      "$contributorCount Petani",
                      style: TextStyle(
                        fontSize: 11,
                        color: isSoldOut
                            ? AppColors.grey600
                            : AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Status badge for sold out
                    if (isSoldOut) ...[
                      const SizedBox(height: 4),
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
