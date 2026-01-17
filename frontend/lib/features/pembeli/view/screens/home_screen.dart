import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/features/pembeli/bloc/home/home_bloc.dart';
import 'package:frontend/features/pembeli/bloc/home/home_event.dart';
import 'package:frontend/features/pembeli/bloc/home/home_state.dart';
import 'package:frontend/features/pembeli/view/widgets/product_card.dart';

/// Refactored Home Screen using BLoC pattern
/// Reduced from ~668 lines to ~250 lines
/// Business logic moved to HomeBloc
/// Reusable widgets: ProductCard
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load initial data - cart/notification counts are loaded
    // automatically after products load (see HomeBloc._onProductsLoadRequested)
    context.read<HomeBloc>().add(const HomeCategoriesLoadRequested());
    context.read<HomeBloc>().add(const HomeProductsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError && mounted) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: PullToRefresh(
              onRefresh: () async {
                // Refresh all data - counts are loaded automatically
                // after HomeRefreshRequested completes (see HomeBloc._onRefreshRequested)
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              },
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              displacement: 40,
              strokeWidth: 2.5,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(state: state),
                      const SizedBox(height: 5),
                      _SearchBar(),
                      const SizedBox(height: 20),
                      _HppBanner(),
                      const SizedBox(height: 25),
                      _CategoriesSection(state: state),
                      const SizedBox(height: 25),
                      _ProductsSection(state: state),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HomeState state;

  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    final loadedState = state is HomeLoaded ? state as HomeLoaded : null;
    final cartCount = loadedState?.cartItemCount ?? 0;
    final notificationCount = loadedState?.unreadNotificationCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage("assets/images/logo.png"),
              ),
              const SizedBox(width: 10),
              const Text(
                "PanenKi'",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () async {
                      await context.push(RoutePaths.cart);
                      // Reload cart count when returning from cart page
                      if (context.mounted) {
                        context.read<HomeBloc>().add(
                          const HomeCartCountRequested(),
                        );
                      }
                    },
                  ),
                  if (cartCount > 0)
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
                          cartCount.toString(),
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
              const SizedBox(width: 12),
              IconButton(
                icon: Badge(
                  label: Text('$notificationCount'),
                  isLabelVisible: notificationCount > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () async {
                  await context.push(RoutePaths.notifications);
                  // Refresh count after returning
                  if (context.mounted) {
                    context.read<HomeBloc>().add(
                      const HomeNotificationCountRequested(),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          context.push(RoutePaths.search);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Text(
                "Gabah",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HppBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          context.push(RoutePaths.hpp);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            "assets/images/hpp.png",
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final HomeState state;

  const _CategoriesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    // Use simple type check instead of switch pattern for reliability
    final loadedState = state is HomeLoaded ? state as HomeLoaded : null;
    final categories = loadedState?.categories ?? <dynamic>[];
    final selectedCategoryId = loadedState?.selectedCategoryId;
    final isLoading =
        state is HomeLoading && (state as HomeLoading).isLoadingCategories;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Kategori",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              if (selectedCategoryId != null)
                GestureDetector(
                  onTap: () {
                    context.read<HomeBloc>().add(
                      const HomeCategorySelected(null),
                    );
                  },
                  child: const Text(
                    "Hapus Filter",
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: AppLoadingIndicator())
        else if (categories.isEmpty)
          const SizedBox()
        else
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategoryId == category['id'];
                return _CategoryChip(
                  title: category['name'] ?? 'Unknown',
                  imagePath: "assets/images/gabah.jpg",
                  isSelected: isSelected,
                  onTap: () {
                    context.read<HomeBloc>().add(
                      HomeCategorySelected(category['id']),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.fromLTRB(3, 3, 16, 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.accent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  final HomeState state;

  const _ProductsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final loadedState = state is HomeLoaded ? state as HomeLoaded : null;
    final products = loadedState?.products ?? <dynamic>[];
    final isLoading =
        state is HomeLoading && (state as HomeLoading).isLoadingProducts;
    final hasError = state is HomeError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Produk",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: AppLoadingIndicator(),
            ),
          )
        else if (hasError)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gagal memuat produk',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<HomeBloc>().add(
                        const HomeRefreshRequested(),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'Tidak ada produk tersedia',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          )
        else
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
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
      ],
    );
  }
}
