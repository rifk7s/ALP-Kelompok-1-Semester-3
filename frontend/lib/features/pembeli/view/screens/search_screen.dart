import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/widgets/app_spacing.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/features/product/service/product_service.dart';
import 'package:frontend/core/utils/product_image_utils.dart';
import 'package:frontend/core/router/route_constants.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> searchHistory = [];
  List<String> filteredHistory = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;

  // Debounce timer for search
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    filteredHistory = List.from(searchHistory);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Perform server-side search with debouncing
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    try {
      final results = await ProductService.searchProducts(query: query);

      if (!mounted) return;
      setState(() {
        searchResults = results.cast<Map<String, dynamic>>();
        isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isSearching = false);
      SnackBarHelper.showError(context, 'Gagal mencari produk');
    }
  }

  void _onSearchChanged(String query) {
    // Update filtered history immediately
    setState(() {
      filteredHistory = searchHistory
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (query.isEmpty) {
        searchResults = [];
        isSearching = false;
      }
    });

    // Debounce the server search
    _debounceTimer?.cancel();
    if (query.isNotEmpty) {
      setState(() => isSearching = true);
      _debounceTimer = Timer(_debounceDuration, () {
        _searchProducts(query);
      });
    }
  }

  void _executeSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      // Add to history
      if (!searchHistory.contains(query)) {
        searchHistory.insert(0, query);
      } else {
        searchHistory.remove(query);
        searchHistory.insert(0, query);
      }
    });

    // Perform search immediately on submit
    _debounceTimer?.cancel();
    _searchProducts(query);
  }

  void _selectHistoryItem(String item) {
    setState(() {
      _controller.text = item;
      // Move to top of history
      if (searchHistory.contains(item)) {
        searchHistory.remove(item);
        searchHistory.insert(0, item);
      }
    });
    _debounceTimer?.cancel();
    _searchProducts(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textLight,
                  ),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                      border: Border.all(
                        color: AppColors.shadowLight,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: _onSearchChanged,
                            onSubmitted: _executeSearch,
                            decoration: const InputDecoration(
                              hintText: "Cari produk...",
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (isSearching)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        else if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              _onSearchChanged('');
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: searchResults.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.70,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final p = searchResults[index];
                  return productCard(context: context, product: p);
                },
              )
            : _controller.text.isNotEmpty && !isSearching
                ? const Center(
                    child: EmptyStateWidget(
                      message: 'Tidak ada produk ditemukan',
                      icon: Icons.search_off,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Riwayat Pencarian",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (searchHistory.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  searchHistory.clear();
                                  filteredHistory.clear();
                                });
                              },
                              child: const Text(
                                "Hapus semua",
                                style: TextStyle(color: AppColors.danger),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: searchHistory.isNotEmpty
                            ? ListView.builder(
                                itemCount: filteredHistory.length,
                                itemBuilder: (context, index) {
                                  final item = filteredHistory[index];
                                  return ListTile(
                                    title: Text(item),
                                    leading: const Icon(
                                      Icons.history,
                                      color: AppColors.textSecondary,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          searchHistory.remove(item);
                                          filteredHistory.remove(item);
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      _selectHistoryItem(item);
                                    },
                                  );
                                },
                              )
                            : const EmptyStateWidget(
                                message: 'Belum ada pencarian',
                                icon: Icons.history,
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

Widget productCard({
  required Map<String, dynamic> product,
  BuildContext? context,
}) {
  final imagePath =
      ProductImageUtils.firstImagePath(product) ?? product['image']?.toString();
  final imageUrl = ApiConfig.getImageUrl(imagePath);

  return GestureDetector(
    onTap: () {
      if (context != null) {
        context.push(
          RoutePaths.productDetail.replaceAll(':id', '${product['id']}'),
          extra: product,
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: AppColors.greyLight,
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: AppColors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.greyLight,
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: AppColors.grey,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Produk',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  CurrencyFormatter.formatRupiah(_parsePrice(product)),
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Stok: ${product['stock_kg'] ?? 0}kg",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        LocationConstants.defaultLocation,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper function to robustly parse price from product map
int _parsePrice(Map<String, dynamic> product) {
  final price = product['price_per_kg'] ?? product['price'];
  if (price is int) return price;
  if (price is double) return price.round();
  if (price is String) {
    return int.tryParse(price) ?? double.tryParse(price)?.round() ?? 0;
  }
  return 0;
}
