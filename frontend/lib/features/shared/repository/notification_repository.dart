import 'package:frontend/features/shared/service/notification_service.dart';

/// Repository layer for notification operations.
/// Wraps NotificationService for unified notification API.
class NotificationRepository {
  /// Get all notifications for current user
  Future<List<Map<String, dynamic>>> getNotifications() async {
    return NotificationService.getNotifications();
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    return NotificationService.getUnreadCount();
  }

  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    return NotificationService.markAsRead(notificationId);
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    return NotificationService.markAllAsRead();
  }
}
