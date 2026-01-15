import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

class NotificationService {
  /// Get all notifications for the current user
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Belum login');
      }

      final response = await apiClient.get('/notifications', token: token);

      if (kDebugMode) {
        debugPrint('Notifications response status: ${response.statusCode}');
        debugPrint('Notifications response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat notifikasi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching notifications: $e');
      }
      rethrow;
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return 0;
      }

      final response = await apiClient.get(
        '/notifications/unread-count',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching unread count: $e');
      }
      rethrow;
    }
  }

  /// Mark a notification as read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Belum login');
      }

      final response = await apiClient.post(
        '/notifications/$notificationId/mark-read',
        token: token,
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking notification as read: $e');
      }
      rethrow;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Belum login');
      }

      final response = await apiClient.post(
        '/notifications/mark-all-read',
        token: token,
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking all notifications as read: $e');
      }
      rethrow;
    }
  }
}
