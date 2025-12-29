import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/order_service.dart';
import 'package:frontend/core/utils/order_status_helper.dart';
import 'package:frontend/core/utils/date_formatter.dart';

/// Transaction state
class TransactionState {
  final List<Map<String, dynamic>> orders;
  final bool isLoading;
  final Map<String, String> countdowns;
  final Set<String> expandedOrders;

  TransactionState({
    this.orders = const [],
    this.isLoading = false,
    this.countdowns = const {},
    this.expandedOrders = const {},
  });

  TransactionState copyWith({
    List<Map<String, dynamic>>? orders,
    bool? isLoading,
    Map<String, String>? countdowns,
    Set<String>? expandedOrders,
  }) {
    return TransactionState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      countdowns: countdowns ?? this.countdowns,
      expandedOrders: expandedOrders ?? this.expandedOrders,
    );
  }
}

/// Transaction event
abstract class TransactionEvent {}

class LoadOrdersEvent extends TransactionEvent {}

class UpdateCountdownsEvent extends TransactionEvent {}

class ToggleOrderExpansionEvent extends TransactionEvent {
  final String orderId;
  ToggleOrderExpansionEvent(this.orderId);
}

/// Transaction Bloc
class TransactionBloc {
  final _stateController = StreamController<TransactionState>.broadcast();
  TransactionState _state = TransactionState();

  Stream<TransactionState> get stream => _stateController.stream;
  TransactionState get state => _state;

  Timer? _countdownTimer;

  TransactionBloc() {
    _startCountdownTimer();
  }

  void emit(TransactionState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  /// Load orders from backend
  Future<void> loadOrders() async {
    emit(_state.copyWith(isLoading: true));
    try {
      final orders = await OrderService.getOrders();
      emit(_state.copyWith(orders: orders, isLoading: false));
      _updateCountdowns();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      emit(_state.copyWith(isLoading: false));
    }
  }

  /// Get orders by status category
  List<Map<String, dynamic>> getOrdersByStatus(String statusCategory) {
    return OrderStatusHelper.filterOrdersByStatus(_state.orders, statusCategory);
  }

  /// Update countdowns for pending orders
  void _updateCountdowns() {
    final newCountdowns = Map<String, String>.from(_state.countdowns);
    
    for (var order in _state.orders) {
      if (order['status'] == 'pending_payment' &&
          order['payment_deadline'] != null) {
        final orderId = order['order_number'] ?? order['id']?.toString() ?? '';
        newCountdowns[orderId] = DateFormatter.calculateTimeLeft(
          order['payment_deadline'],
        );
      }
    }
    
    emit(_state.copyWith(countdowns: newCountdowns));
  }

  /// Start countdown timer
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdowns();
    });
  }

  /// Toggle order expansion
  void toggleOrderExpansion(String orderId) {
    final newExpanded = Set<String>.from(_state.expandedOrders);
    if (newExpanded.contains(orderId)) {
      newExpanded.remove(orderId);
    } else {
      newExpanded.add(orderId);
    }
    emit(_state.copyWith(expandedOrders: newExpanded));
  }

  /// Check if order is expanded
  bool isOrderExpanded(String orderId) {
    return _state.expandedOrders.contains(orderId);
  }

  /// Get countdown for specific order
  String? getCountdown(String orderId) {
    return _state.countdowns[orderId];
  }

  /// Cancel order
  Future<bool> cancelOrder(int orderId) async {
    try {
      final success = await OrderService.cancelOrder(orderId);
      if (success) {
        await loadOrders();
      }
      return success;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }

  /// Complete order
  Future<bool> completeOrder(int orderId) async {
    try {
      final success = await OrderService.completeOrder(orderId);
      if (success) {
        await loadOrders();
      }
      return success;
    } catch (e) {
      debugPrint('Error completing order: $e');
      return false;
    }
  }

  void dispose() {
    _countdownTimer?.cancel();
    _stateController.close();
  }
}
