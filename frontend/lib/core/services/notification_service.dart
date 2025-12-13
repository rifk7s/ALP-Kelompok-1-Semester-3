import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  /// Get all notifications for the current user
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('Notifications response status: ${response.statusCode}');
        debugPrint('Notifications response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching notifications: $e');
      }
      return [];
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return 0;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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
      return 0;
    }
  }

  /// Mark a notification as read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/notifications/$notificationId/mark-read',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking notification as read: $e');
      }
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking all notifications as read: $e');
      }
      return false;
    }
  }
}
