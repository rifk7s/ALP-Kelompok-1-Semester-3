import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/features/bumdes/bloc/transaction_bumdes_bloc.dart';
import 'package:frontend/features/bumdes/utils/transaction_bumdes_helper.dart';
import 'package:frontend/features/bumdes/view/widgets/transaction_bumdes_widgets.dart';
import 'package:frontend/features/bumdes/view/widgets/transaction_bumdes_actions.dart';

class BumdesTransactionPage extends StatefulWidget {
  final int? initialTab;

  const BumdesTransactionPage({super.key, this.initialTab});

  @override
  State<BumdesTransactionPage> createState() => _BumdesTransactionPageState();
}

class _BumdesTransactionPageState extends State<BumdesTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TransactionBumdesBloc _bloc;

  final List<String> _statusFlow = [
    'pending_payment',
    'processing',
    'shipped',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _statusFlow.length,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _bloc = TransactionBumdesBloc();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await _bloc.loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Transaksi BUMDes',
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
          Tab(text: 'Baru'),
          Tab(text: 'Dikemas'),
          Tab(text: 'Dikirim'),
          Tab(text: 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<TransactionBumdesState>(
      stream: _bloc.stream,
      initialData: _bloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return RetryableContent(
          isLoading: state.isLoading,
          hasError: state.hasError,
          errorMessage: state.errorMessage ?? 'Gagal memuat data transaksi',
          onRetry: _loadOrders,
          child: TabBarView(
            controller: _tabController,
            children: _statusFlow
                .map((status) => _buildOrderList(status))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildOrderList(String status) {
    return PullToRefresh(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      displacement: 36,
      strokeWidth: 2.5,
      child: _buildOrderListContent(status),
    );
  }

  Widget _buildOrderListContent(String status) {
    return StreamBuilder<TransactionBumdesState>(
      stream: _bloc.stream,
      initialData: _bloc.state,
      builder: (context, snapshot) {
        final filteredOrders = _bloc.getOrdersByStatus(status);

        if (filteredOrders.isEmpty) {
          return BumdesEmptyState(status: status);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: filteredOrders.length,
          itemBuilder: (_, index) => _orderCard(filteredOrders[index]),
        );
      },
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final orderId = order['id'] as int;
    final createdAt = order['created_at'] as String?;
    final hasProofImage = TransactionBumdesHelper.hasPaymentProof(order);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          BumdesOrderCardHeader(
            status: status,
            orderNumber: order['order_number'] as String,
            hasProofImage: hasProofImage,
          ),

          // Order items
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: BumdesOrderItemsList(
              order: order,
              isExpanded: _bloc.isOrderExpanded(orderId),
              onToggleExpand: () => _bloc.toggleOrderExpansion(orderId),
            ),
          ),

          // Order info
          BumdesOrderInfo(order: order),

          // Progress section
          BumdesOrderProgress(
            status: status,
            createdAt: createdAt ?? '',
            hasProofImage: hasProofImage,
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: BumdesOrderActions(
              order: order,
              onAdvanceStatus: () => _handleAdvanceStatus(orderId, status),
              onOpenTracking: () => _handleOpenTracking(order),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAdvanceStatus(int orderId, String currentStatus) async {
    final success = await _bloc.advanceStatus(orderId, currentStatus);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui status')));
    }
  }

  void _handleOpenTracking(Map<String, dynamic> order) {
    BumdesTrackingHelper.openTracking(context, order);
  }
}
