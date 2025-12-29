import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  final bool isLoadingCategories;
  final bool isLoadingProducts;

  const HomeLoading({
    this.isLoadingCategories = true,
    this.isLoadingProducts = true,
  });

  @override
  List<Object?> get props => [isLoadingCategories, isLoadingProducts];
}

class HomeLoaded extends HomeState {
  final List<dynamic> categories;
  final List<dynamic> products;
  final int? selectedCategoryId;
  final int cartItemCount;
  final int unreadNotificationCount;

  const HomeLoaded({
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId,
    this.cartItemCount = 0,
    this.unreadNotificationCount = 0,
  });

  bool get hasErrorCategories => false;
  bool get hasErrorProducts => false;

  HomeLoaded copyWith({
    List<dynamic>? categories,
    List<dynamic>? products,
    int? selectedCategoryId,
    int? cartItemCount,
    int? unreadNotificationCount,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    products,
    selectedCategoryId,
    cartItemCount,
    unreadNotificationCount,
  ];
}

class HomeError extends HomeState {
  final String message;
  final bool isCategoriesError;

  const HomeError({required this.message, this.isCategoriesError = false});

  @override
  List<Object?> get props => [message, isCategoriesError];
}
