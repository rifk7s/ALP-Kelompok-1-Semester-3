import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {
  final bool showSpinner;

  const CartLoadRequested({this.showSpinner = true});

  @override
  List<Object?> get props => [showSpinner];
}

class CartItemQuantityChanged extends CartEvent {
  final Map<String, dynamic> item;
  final double newQty;

  const CartItemQuantityChanged({required this.item, required this.newQty});

  @override
  List<Object?> get props => [item, newQty];
}

class CartItemRemoved extends CartEvent {
  final int cartId;

  const CartItemRemoved(this.cartId);

  @override
  List<Object?> get props => [cartId];
}

class CartItemSelectedToggled extends CartEvent {
  final int itemId;
  final bool isSelected;

  const CartItemSelectedToggled({
    required this.itemId,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [itemId, isSelected];
}

class CartSelectAllToggled extends CartEvent {
  final bool selectAll;

  const CartSelectAllToggled(this.selectAll);

  @override
  List<Object?> get props => [selectAll];
}

class CartRecommendationsLoadRequested extends CartEvent {
  const CartRecommendationsLoadRequested();
}

class CartStockValidated extends CartEvent {
  final List<Map<String, dynamic>> selectedItems;

  const CartStockValidated(this.selectedItems);

  @override
  List<Object?> get props => [selectedItems];
}
