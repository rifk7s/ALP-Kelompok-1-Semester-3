import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {
  final bool showSpinner;

  const CartLoading({this.showSpinner = true});

  @override
  List<Object?> get props => [showSpinner];
}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> cartItems;
  final Map<int, bool> selectedItems;
  final List<Map<String, dynamic>> recommendations;
  final int subtotal;
  final int shippingCost;
  final int total;
  final Set<int> updatingItems;
  final bool selectAll;

  const CartLoaded({
    this.cartItems = const [],
    this.selectedItems = const {},
    this.recommendations = const [],
    this.subtotal = 0,
    this.shippingCost = 0,
    this.total = 0,
    this.updatingItems = const {},
    this.selectAll = false,
  });

  int get totalPrice {
    int sum = 0;
    for (var item in cartItems) {
      if (selectedItems[item['id']] == true) {
        final qty = double.parse(item['quantity_kg'].toString());
        final price = double.parse(item['product']['price_per_kg'].toString());
        sum += (qty * price).toInt();
      }
    }
    return sum;
  }

  int get totalSelectedItems =>
      selectedItems.values.where((selected) => selected).length;

  CartLoaded copyWith({
    List<Map<String, dynamic>>? cartItems,
    Map<int, bool>? selectedItems,
    List<Map<String, dynamic>>? recommendations,
    int? subtotal,
    int? shippingCost,
    int? total,
    Set<int>? updatingItems,
    bool? selectAll,
  }) {
    return CartLoaded(
      cartItems: cartItems ?? this.cartItems,
      selectedItems: selectedItems ?? this.selectedItems,
      recommendations: recommendations ?? this.recommendations,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      updatingItems: updatingItems ?? this.updatingItems,
      selectAll: selectAll ?? this.selectAll,
    );
  }

  @override
  List<Object?> get props => [
    cartItems,
    selectedItems,
    recommendations,
    subtotal,
    shippingCost,
    total,
    updatingItems,
    selectAll,
  ];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

class CartStockValidationResult extends CartState {
  final bool isValid;
  final String? errorMessage;

  const CartStockValidationResult({required this.isValid, this.errorMessage});

  @override
  List<Object?> get props => [isValid, errorMessage];
}
