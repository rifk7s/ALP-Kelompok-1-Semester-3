import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/features/shared/service/notification_service.dart';
import 'package:frontend/features/pembeli/service/order_service.dart';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/features/shared/service/chat_service.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final notifications = await NotificationService.getNotifications();

    // Sort: unread first, then by created_at descending (newest first)
    notifications.sort((a, b) {
      final aIsRead = a['is_read'] == 1 || a['is_read'] == true;
      final bIsRead = b['is_read'] == 1 || b['is_read'] == true;

      // If read status differs, unread comes first
      if (aIsRead != bIsRead) {
        return aIsRead ? 1 : -1;
      }

      // If same read status, sort by created_at descending
      final aTime = a['created_at'] as String? ?? '';
      final bTime = b['created_at'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return DateFormat('d MMM yyyy', 'id_ID').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
      case 'chat':
        return Icons.chat;
      case 'product':
        return Icons.inventory;
      default:
        return Icons.notifications;
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    final isRead = _notifications[index]['is_read'];
    if (isRead == 1 || isRead == true) return;

    final success = await NotificationService.markAsRead(notificationId);
    if (success && mounted) {
      setState(() {
        _notifications[index]['is_read'] = true;
      });
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    // Mark as read first
    final notificationId = notification['id'] ?? 0;
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      await _markAsRead(notificationId, index);
    }

    final type = notification['type'] as String?;
    final relatedId = notification['related_id']?.toString();

    if (type == 'order' || type == 'payment') {
      // Check user role to determine navigation
      final user = await StorageService.getUser();
      final userRole = user?['role'] as String?;
      final isBumdes = userRole == 'admin' || userRole == 'bumdes';

      if (relatedId != null && mounted) {
        if (isBumdes) {
          // Navigate to BUMDes transaction page
          try {
            if (mounted) {
              context.push(RoutePaths.bumdesHome, extra: {'initialTab': 2});
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error fetching order: $e');
            }
            // If error, just navigate to transaction page
            if (mounted) {
              context.push(RoutePaths.bumdesHome, extra: {'initialTab': 2});
            }
          }
        } else {
          // Navigate to Pembeli transaction history
          try {
            final orders = await OrderService.getOrders();
            final order = orders.firstWhere(
              (o) => o['id'].toString() == relatedId,
              orElse: () => <String, dynamic>{},
            );

            int initialTab = 0;
            if (order.isNotEmpty) {
              final status = order['status'] as String?;
              if (kDebugMode) {
                debugPrint('Order status: $status for order ID: $relatedId');
              }
              if (status == 'pending_payment') {
                initialTab = 0; // Belum Bayar
              } else if (status == 'paid' ||
                  status == 'processing' ||
                  status == 'shipped') {
                initialTab = 1; // Diproses
              } else if (status == 'completed' || status == 'rejected') {
                initialTab = 2; // Selesai
              }
            }

            if (mounted) {
              context.push(
                RoutePaths.transactionHistory,
                extra: {'initialTab': initialTab},
              );
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error fetching order: $e');
            }
            // If error, just navigate to transaction history
            if (mounted) {
              context.push(RoutePaths.transactionHistory);
            }
          }
        }
      }
    } else if (type == 'chat') {
      // Navigate to chat
      if (relatedId != null && mounted) {
        try {
          // Sign in to Firebase first
          await ChatService.signInToFirebase();

          // Get chat document to retrieve participant info
          final chatDoc = await ChatService.getChatDocument(relatedId);
          if (chatDoc != null) {
            final currentUserId = ChatService.getCurrentUserId();
            final participants =
                chatDoc['participants'] as List<dynamic>? ?? [];
            final participantNames =
                chatDoc['participantNames'] as Map<String, dynamic>? ?? {};
            final participantImages =
                chatDoc['participantImages'] as Map<String, dynamic>? ?? {};

            // Get the other participant's info
            String recipientId = '';
            String recipientName = 'Pengguna';
            String? recipientImage;

            for (final participantId in participants) {
              if (participantId != currentUserId) {
                recipientId = participantId;
                recipientName = participantNames[participantId] ?? 'Pengguna';
                recipientImage = participantImages[participantId];
                break;
              }
            }

            if (mounted) {
              context.push(
                RoutePaths.chat,
                extra: {
                  'chatId': relatedId,
                  'name': recipientName,
                  'image': recipientImage ?? '',
                  'recipientId': recipientId,
                },
              );
            }
          } else {
            if (mounted) {
              SnackBarHelper.showError(context, 'Chat tidak ditemukan');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error navigating to chat: $e');
          }
          if (mounted) {
            SnackBarHelper.showError(context, 'Gagal membuka chat: $e');
          }
        }
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await NotificationService.markAllAsRead();
    if (success && mounted) {
      setState(() {
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }
      });
      SnackBarHelper.showSuccess(context, 'Semua notifikasi ditandai sudah dibaca');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        actions: [
          if (_notifications.any(
            (n) => n['is_read'] == 0 || n['is_read'] == false,
          ))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tandai Semua Dibaca',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppLoadingIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification['is_read'];
                  final isReadBool = (isRead == 1 || isRead == true);
                  return notifItem(
                    id: notification['id'] ?? 0,
                    title: notification['title'] ?? '',
                    message: notification['message'] ?? '',
                    time: _formatTime(notification['created_at'] ?? ''),
                    isUnread: !isReadBool,
                    icon: _getIconForType(notification['type'] ?? ''),
                    onTap: () => _handleNotificationTap(notification),
                  );
                },
              ),
            ),
    );
  }

  Widget notifItem({
    required int id,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.white : AppColors.grey200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? AppColors.primaryLight.withValues(alpha: 0.3)
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isUnread ? AppColors.primary : AppColors.grey600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isUnread
                              ? AppColors.textLight
                              : AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread
                              ? AppColors.grey800
                              : AppColors.grey600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isUnread
                              ? AppColors.textSecondary
                              : AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.notificationDivider),
          ],
        ),
      ),
    );
  }
}
