import 'package:equatable/equatable.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final Map<String, dynamic> product;
  final int cartItemCount;
  final int selectedQty;
  final double qtyInCart;

  const ProductDetailLoaded({
    required this.product,
    this.cartItemCount = 0,
    this.selectedQty = 1,
    this.qtyInCart = 0,
  });

  int get parsedPrice {
    final pricePerKg = double.parse(product['price_per_kg'].toString());
    return pricePerKg.toInt();
  }

  double get stockKg {
    return double.parse(product['stock_kg'].toString());
  }

  double get availableStock => stockKg - qtyInCart;

  int get total => parsedPrice * selectedQty;

  ProductDetailLoaded copyWith({
    Map<String, dynamic>? product,
    int? cartItemCount,
    int? selectedQty,
    double? qtyInCart,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      selectedQty: selectedQty ?? this.selectedQty,
      qtyInCart: qtyInCart ?? this.qtyInCart,
    );
  }

  @override
  List<Object?> get props => [product, cartItemCount, selectedQty, qtyInCart];
}

class ProductDetailAddingToCart extends ProductDetailState {}

class ProductDetailAddedToCart extends ProductDetailState {
  final int newCartCount;

  const ProductDetailAddedToCart(this.newCartCount);

  @override
  List<Object?> get props => [newCartCount];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductDetailStockValidation extends ProductDetailState {
  final bool isValid;
  final String? errorMessage;

  const ProductDetailStockValidation({
    required this.isValid,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isValid, errorMessage];
}
