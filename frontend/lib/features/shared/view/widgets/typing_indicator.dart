import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  static const double bubbleHeight = 28;
  static const double bubbleWidth = 54;
  static const double verticalMargin = 12;
  static const double totalHeight = bubbleHeight + verticalMargin;

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _offsets = const [0.0, 0.2, 0.4];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SizedBox(
            width: TypingBubble.bubbleWidth,
            height: TypingBubble.bubbleHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (index) => _PulsingDot(
                    controller: _controller,
                    offset: _offsets[index],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.controller, required this.offset});

  final AnimationController controller;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + offset) % 1.0;
        final eased = Curves.easeInOut.transform(t);
        final sine = math.sin(eased * math.pi);
        final scale = 0.7 + 0.3 * sine;
        final opacity = 0.45 + 0.55 * sine;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
