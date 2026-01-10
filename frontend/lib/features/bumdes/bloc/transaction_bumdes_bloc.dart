import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/features/bumdes/service/admin_service.dart';

/// Transaction Bumdes state
class TransactionBumdesState {
  final List<Map<String, dynamic>> orders;
  final bool isLoading;
  final bool hasError;
  final Set<int> expandedOrders;
  final String? errorMessage;

  TransactionBumdesState({
    this.orders = const [],
    this.isLoading = false,
    this.hasError = false,
    this.expandedOrders = const {},
    this.errorMessage,
  });

  TransactionBumdesState copyWith({
    List<Map<String, dynamic>>? orders,
    bool? isLoading,
    bool? hasError,
    Set<int>? expandedOrders,
    String? errorMessage,
  }) {
    return TransactionBumdesState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      expandedOrders: expandedOrders ?? this.expandedOrders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Transaction Bumdes event
abstract class TransactionBumdesEvent {}

class LoadOrdersEvent extends TransactionBumdesEvent {}

class ToggleOrderExpansionEvent extends TransactionBumdesEvent {
  final int orderId;
  ToggleOrderExpansionEvent(this.orderId);
}

class AdvanceStatusEvent extends TransactionBumdesEvent {
  final int orderId;
  final String currentStatus;
  AdvanceStatusEvent(this.orderId, this.currentStatus);
}

/// Transaction Bumdes Bloc
class TransactionBumdesBloc {
  final _stateController = StreamController<TransactionBumdesState>.broadcast();
  TransactionBumdesState _state = TransactionBumdesState();

  Stream<TransactionBumdesState> get stream => _stateController.stream;
  TransactionBumdesState get state => _state;

  void emit(TransactionBumdesState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  /// Load orders from backend
  Future<void> loadOrders() async {
    emit(_state.copyWith(isLoading: true, hasError: false));
    try {
      final orders = await AdminService.getOrdersByStatus();
      emit(_state.copyWith(orders: orders, isLoading: false));
    } catch (e) {
      debugPrint('Error loading orders: $e');
      emit(
        _state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Gagal memuat data transaksi',
        ),
      );
    }
  }

  /// Get orders by status category
  List<Map<String, dynamic>> getOrdersByStatus(String status) {
    if (status == 'pending_payment') {
      // Baru tab shows both pending_payment and paid orders
      final filtered = _state.orders
          .where(
            (order) =>
                order['status'] == 'pending_payment' ||
                order['status'] == 'paid',
          )
          .toList();

      // Sort by updated_at or created_at (newest first)
      filtered.sort((a, b) {
        final aTime =
            a['updated_at'] as String? ?? a['created_at'] as String? ?? '';
        final bTime =
            b['updated_at'] as String? ?? b['created_at'] as String? ?? '';
        return bTime.compareTo(aTime);
      });

      return filtered;
    } else if (status == 'completed') {
      // Selesai tab shows both completed and rejected orders
      // Keep original sorting from backend (by completion timestamp)
      return _state.orders
          .where(
            (order) =>
                order['status'] == 'completed' || order['status'] == 'rejected',
          )
          .toList();
    } else {
      final filtered = _state.orders
          .where((order) => order['status'] == status)
          .toList();

      // Sort by updated_at or created_at (newest first)
      filtered.sort((a, b) {
        final aTime =
            a['updated_at'] as String? ?? a['created_at'] as String? ?? '';
        final bTime =
            b['updated_at'] as String? ?? b['created_at'] as String? ?? '';
        return bTime.compareTo(aTime);
      });

      return filtered;
    }
  }

  /// Toggle order expansion
  void toggleOrderExpansion(int orderId) {
    final newExpanded = Set<int>.from(_state.expandedOrders);
    if (newExpanded.contains(orderId)) {
      newExpanded.remove(orderId);
    } else {
      newExpanded.add(orderId);
    }
    emit(_state.copyWith(expandedOrders: newExpanded));
  }

  /// Check if order is expanded
  bool isOrderExpanded(int orderId) {
    return _state.expandedOrders.contains(orderId);
  }

  /// Advance order status
  Future<bool> advanceStatus(int orderId, String currentStatus) async {
    bool success = false;

    switch (currentStatus) {
      case 'pending_payment':
        success = await AdminService.confirmPayment(orderId);
        break;
      case 'paid':
        success = await AdminService.markProcessing(orderId);
        break;
      case 'processing':
        success = await AdminService.markShipped(orderId);
        break;
    }

    if (success) {
      await loadOrders();
    }

    return success;
  }

  void dispose() {
    _stateController.close();
  }
}
