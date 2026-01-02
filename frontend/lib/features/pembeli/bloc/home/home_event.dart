import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeCategoriesLoadRequested extends HomeEvent {
  const HomeCategoriesLoadRequested();
}

class HomeProductsLoadRequested extends HomeEvent {
  final int? categoryId;
  final bool showLoading;

  const HomeProductsLoadRequested({this.categoryId, this.showLoading = true});

  @override
  List<Object?> get props => [categoryId, showLoading];
}

class HomeCategorySelected extends HomeEvent {
  final int? categoryId;

  const HomeCategorySelected(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class HomeCartCountRequested extends HomeEvent {
  const HomeCartCountRequested();
}

class HomeNotificationCountRequested extends HomeEvent {
  const HomeNotificationCountRequested();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Reset home state (used when user logs out)
class HomeReset extends HomeEvent {
  const HomeReset();
}
