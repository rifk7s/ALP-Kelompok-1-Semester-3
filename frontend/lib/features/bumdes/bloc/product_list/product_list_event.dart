import 'package:equatable/equatable.dart';

/// Events for ProductListBloc (BUMDes product listing)
abstract class ProductListEvent extends Equatable {
  const ProductListEvent();
  @override
  List<Object?> get props => [];
}

/// Request to load products
class ProductListLoadRequested extends ProductListEvent {
  /// If true, shows loading spinner; false for silent refresh
  final bool showSpinner;

  /// If true, forces cache refresh
  final bool forceRefresh;

  const ProductListLoadRequested({
    this.showSpinner = true,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [showSpinner, forceRefresh];
}

/// Filter changed (all, available, empty)
class ProductListFilterChanged extends ProductListEvent {
  final String filter;

  const ProductListFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Search query changed
class ProductListSearchChanged extends ProductListEvent {
  final String query;

  const ProductListSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Reset bloc state
class ProductListReset extends ProductListEvent {
  const ProductListReset();
}
