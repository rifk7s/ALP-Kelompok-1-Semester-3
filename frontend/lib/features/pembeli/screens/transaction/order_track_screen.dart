import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class OrderTrackingPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with SingleTickerProviderStateMixin {
  final List<String> _stages = [
    'Pesanan Dibuat',
    'Dikemas',
    'Dikirim',
    'Selesai',
  ];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentStage = _stages.indexOf(widget.order['statusText']);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Lacak Pesanan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Card produk
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.order['productImage'] ??
                              'assets/images/gabah.jpg',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order['seller'] ?? 'BUMDes Desa Sengka',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.order['id'] ?? '#ORD-XXXX-XXX',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Timeline
                ..._stages.asMap().entries.map((entry) {
                  int index = entry.key;
                  String stage = entry.value;
                  bool completed = index < currentStage;
                  bool isCurrent = index == currentStage;
                  return _buildStageTile(
                    stage,
                    completed,
                    isCurrent,
                    widget.order['timestamps'],
                    index == _stages.length - 1,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageTile(
    String title,
    bool completed,
    bool isCurrent,
    Map<String, String>? timestamps,
    bool isLast,
  ) {
    Color circleColor = completed || isCurrent
        ? AppColors.primary
        : Colors.grey[300]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                double scale = isCurrent ? 1 + _controller.value * 0.3 : 1;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: completed || isCurrent
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [circleColor, Colors.grey[300]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: completed || isCurrent
                        ? Colors.black87
                        : Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
                if ((completed || isCurrent) &&
                    timestamps != null &&
                    timestamps[title] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      timestamps[title]!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
