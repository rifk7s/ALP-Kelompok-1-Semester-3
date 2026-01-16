import 'package:equatable/equatable.dart';

/// State for ProductListBloc (BUMDes product listing)
class ProductListState extends Equatable {
  /// All loaded products (unfiltered)
  final List<Map<String, dynamic>> products;

  /// Current filter: 'all', 'available', 'empty'
  final String filter;

  /// Current search query
  final String searchQuery;

  /// Whether data is loading
  final bool isLoading;

  /// Whether there's an error
  final bool hasError;

  /// Error message if any
  final String? errorMessage;

  const ProductListState({
    this.products = const [],
    this.filter = 'all',
    this.searchQuery = '',
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  /// Get filtered products based on current filter and search
  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> temp = products.where((p) {
      final status = p['status'].toString();

      // Filter by stock status
      if (filter == 'available' && status == 'sold_out') return false;
      if (filter == 'empty' && status == 'active') return false;

      // Filter by search query
      if (searchQuery.isNotEmpty &&
          !p['name'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              )) {
        return false;
      }
      return true;
    }).toList();

    // Sort: active products first, sold_out at bottom
    temp.sort((a, b) {
      if (a['status'] == 'active' && b['status'] == 'sold_out') return -1;
      if (a['status'] == 'sold_out' && b['status'] == 'active') return 1;
      return 0;
    });

    return temp;
  }

  ProductListState copyWith({
    List<Map<String, dynamic>>? products,
    String? filter,
    String? searchQuery,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return ProductListState(
      products: products ?? this.products,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        products,
        filter,
        searchQuery,
        isLoading,
        hasError,
        errorMessage,
      ];
}
