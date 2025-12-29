import 'package:equatable/equatable.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailLoadRequested extends ProductDetailEvent {
  final int productId;

  const ProductDetailLoadRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductDetailCartCountRequested extends ProductDetailEvent {
  const ProductDetailCartCountRequested();
}

class ProductDetailQuantityChanged extends ProductDetailEvent {
  final int newQty;

  const ProductDetailQuantityChanged(this.newQty);

  @override
  List<Object?> get props => [newQty];
}

class ProductDetailAddToCartRequested extends ProductDetailEvent {
  final int productId;
  final double quantityKg;

  const ProductDetailAddToCartRequested({
    required this.productId,
    required this.quantityKg,
  });

  @override
  List<Object?> get props => [productId, quantityKg];
}

class ProductDetailStockValidated extends ProductDetailEvent {
  final int productId;
  final double desiredQty;

  const ProductDetailStockValidated({
    required this.productId,
    required this.desiredQty,
  });

  @override
  List<Object?> get props => [productId, desiredQty];
}
