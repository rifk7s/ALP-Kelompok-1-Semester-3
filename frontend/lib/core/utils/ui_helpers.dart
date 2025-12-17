import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

/// Simple reusable pull-to-refresh wrapper.
class PullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double strokeWidth;

  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement = 40,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
      displacement: displacement,
      strokeWidth: strokeWidth,
      child: child,
    );
  }
}

/// Detect multi-finger pull-down and trigger refresh without blocking scroll.
class MultiFingerRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final int fingerCount;
  final double triggerDistance;

  const MultiFingerRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.fingerCount = 3,
    this.triggerDistance = 80,
  });

  @override
  State<MultiFingerRefresh> createState() => _MultiFingerRefreshState();
}

class _MultiFingerRefreshState extends State<MultiFingerRefresh> {
  final Map<int, Offset> _pointers = {};
  Offset? _start;
  bool _triggered = false;
  bool _isRefreshing = false;

  void _resetGesture() {
    _start = null;
    _triggered = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _pointers[event.pointer] = event.position;
        if (_pointers.length >= widget.fingerCount) {
          _start = event.position;
          _triggered = false;
        }
      },
      onPointerMove: (event) {
        if (_pointers.length >= widget.fingerCount) {
          _start ??= event.position;
          final dy = event.position.dy - (_start?.dy ?? event.position.dy);
          if (!_triggered && !_isRefreshing && dy > widget.triggerDistance) {
            _triggered = true;
            _isRefreshing = true;
            widget.onRefresh().whenComplete(() {
              if (mounted) {
                setState(() => _isRefreshing = false);
              } else {
                _isRefreshing = false;
              }
            });
          }
        }
      },
      onPointerUp: (event) {
        _pointers.remove(event.pointer);
        if (_pointers.length < widget.fingerCount) {
          _resetGesture();
        }
      },
      onPointerCancel: (event) {
        _pointers.remove(event.pointer);
        if (_pointers.length < widget.fingerCount) {
          _resetGesture();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

/// Helper to show snackbar with anti-spam throttle
class SnackBarHelper {
  static bool _isShowing = false;
  static Timer? _throttleTimer;

  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    // THROTTLE: Block rapid calls completely
    if (_isShowing) return;

    _isShowing = true;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );

    // Reset flag after duration + animation time
    _throttleTimer?.cancel();
    _throttleTimer = Timer(duration + const Duration(milliseconds: 300), () {
      _isShowing = false;
    });
  }

  static void showError(BuildContext context, String message) {
    show(context, message, backgroundColor: AppColors.danger);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, backgroundColor: AppColors.success);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message);
  }
}

/// Debouncer to prevent rapid button clicks
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Button debouncer mixin to prevent spam clicks
mixin ButtonDebounceMixin<T extends StatefulWidget> on State<T> {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  Future<void> debounceAction(Future<void> Function() action) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

/// Dialog manager to prevent multiple dialogs
class DialogManager {
  static bool _isDialogOpen = false;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    if (_isDialogOpen) return null;

    _isDialogOpen = true;

    try {
      final result = await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );
      return result;
    } finally {
      _isDialogOpen = false;
    }
  }

  static Future<T?> showAlert<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) async {
    if (_isDialogOpen) return null;

    return show<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.pop(context, true);
            },
            child: Text(confirmText ?? 'OK'),
          ),
        ],
      ),
    );
  }
}

/// ShakeWidget - Animasi shake untuk form validation error
/// Usage: Wrap TextField dengan ShakeWidget, lalu panggil shakeKey.currentState?.shake()
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration duration;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shakeOffset = 10.0,
    this.shakeCount = 3,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _ShakeCurve(widget.shakeCount),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger shake animation
  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * widget.shakeOffset, 0),
          child: child,
        );
      },
    );
  }
}

/// Custom curve untuk efek shake bolak-balik
class _ShakeCurve extends Curve {
  final int count;

  const _ShakeCurve(this.count);

  @override
  double transformInternal(double t) {
    return math.sin(t * math.pi * count * 2) * (1 - t);
  }
}

/// RetryableContent - Widget untuk menampilkan error state dengan tombol retry
/// Usage: Wrap konten dengan RetryableContent, set hasError dan onRetry
class RetryableContent extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Widget child;
  final Widget? loadingWidget;
  final IconData? errorIcon;

  const RetryableContent({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.child,
    this.errorMessage,
    this.loadingWidget,
    this.errorIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                errorIcon ?? Icons.error_outline,
                size: 64,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Terjadi kesalahan saat memuat data',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}

/// EmptyStateWidget - Widget untuk menampilkan state kosong
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subMessage,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
