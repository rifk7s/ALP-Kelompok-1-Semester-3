import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/features/pembeli/screens/product_detail_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> searchHistory = [
    "Gabah Kering",
    "Jagung Pipilan",
    "Padi Ciherang",
    "Cabe Merah",
  ];

  List<String> filteredHistory = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> _allProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filteredHistory = List.from(searchHistory);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final products = await ProductService.getProducts();
      setState(() {
        _allProducts = products.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredHistory = searchHistory
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = _allProducts
            .where(
              (p) => (p['name'] as String).toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _addToHistory(String query) {
    if (query.isEmpty) return;
    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
    } else {
      searchHistory.remove(query);
      searchHistory.insert(0, query);
    }
    _controller.clear();
    _onSearchChanged('');
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textLight,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.shadowLight,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                            onSubmitted: _addToHistory,
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
                        if (_controller.text.isNotEmpty)
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
                  return productCard(
                    context: context,
                    product: p,
                  );
                },
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
                              _onSearchChanged('');
                            });
                          },
                          child: const Text(
                            "Hapus semua",
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                                      _onSearchChanged(_controller.text);
                                    });
                                  },
                                ),
                                onTap: () {
                                  _addToHistory(item);
                                  _onSearchChanged(item);
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              "Belum ada pencarian",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
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
  return GestureDetector(
    onTap: () {
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
            ),
          ),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
            child: product['image'] != null
                ? Image.network(
                    ApiConfig.getImageUrl(product['image']),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
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
                const SizedBox(height: 6),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(product['price'] ?? 0),
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Stok: ${product['stock_kg'] ?? 0}kg",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
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
                        "Sengka, Gowa",
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
