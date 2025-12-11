import 'dart:async';
import 'package:flutter/material.dart';

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
    show(context, message, backgroundColor: Colors.red);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.green);
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
