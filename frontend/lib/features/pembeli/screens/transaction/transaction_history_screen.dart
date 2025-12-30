import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/features/pembeli/bloc/transaction/transaction_bloc.dart';
import 'package:frontend/features/pembeli/bloc/transaction/transaction_provider.dart';
import 'package:frontend/features/pembeli/widgets/transaction/order_card.dart';
import 'package:frontend/features/pembeli/screens/transaction/transaction_actions_controller.dart';

/// Refactored Transaction History Screen
/// Uses Bloc for state management and separated widgets for UI
class TransactionHistoryPage extends StatefulWidget {
  final int initialTab;

  const TransactionHistoryPage({super.key, this.initialTab = 0});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TransactionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _bloc = TransactionBloc();
    _bloc.loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TransactionProvider(
      bloc: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Belum Bayar'),
              Tab(text: 'Diproses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _OrderListTab(statusCategory: 'pending'),
            _OrderListTab(statusCategory: 'processing'),
            _OrderListTab(statusCategory: 'completed'),
          ],
        ),
      ),
    );
  }
}

/// Separate widget for each tab's content
class _OrderListTab extends StatelessWidget {
  final String statusCategory;

  const _OrderListTab({required this.statusCategory});

  @override
  Widget build(BuildContext context) {
    final bloc = TransactionProvider.of(context);

    return StreamBuilder<TransactionState>(
      stream: bloc.stream,
      initialData: bloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        if (state.isLoading) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }

        final orders = bloc.getOrdersByStatus(statusCategory);

        return PullToRefresh(
          onRefresh: () => bloc.loadOrders(),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          displacement: 36,
          strokeWidth: 2.5,
          child: orders.isEmpty
              ? _buildEmptyState(statusCategory)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order['order_number'] ?? order['id']?.toString() ?? '';
                    final bloc = TransactionProvider.of(context);

                    return OrderCard(
                      order: order,
                      isExpanded: bloc.isOrderExpanded(orderId),
                      onToggleExpand: () => bloc.toggleOrderExpansion(orderId),
                      onProductTap: () => TransactionActionsController.openTracking(context, order),
                      onCancel: (id) async {
                        await bloc.cancelOrder(id);
                      },
                      onComplete: (id) async {
                        await bloc.completeOrder(id);
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'pending':
        message = 'Tidak ada pesanan yang belum dibayar';
        icon = Icons.payment_outlined;
        break;
      case 'processing':
        message = 'Tidak ada pesanan yang sedang diproses';
        icon = Icons.local_shipping_outlined;
        break;
      case 'completed':
        message = 'Belum ada pesanan selesai';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'Tidak ada pesanan';
        icon = Icons.inbox_outlined;
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 120),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
