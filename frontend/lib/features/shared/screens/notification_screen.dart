import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/notification_service.dart';
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

  Future<void> _markAllAsRead() async {
    final success = await NotificationService.markAllAsRead();
    if (success && mounted) {
      setState(() {
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca')),
      );
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
          if (_notifications.any((n) => n['is_read'] == 0 || n['is_read'] == false))
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
          ? const Center(child: CircularProgressIndicator())
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
                        onTap: () => _markAsRead(
                          notification['id'] ?? 0,
                          index,
                        ),
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
                        ? AppColors.primaryLight.withOpacity(0.3)
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
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w500,
                          color: isUnread ? AppColors.textLight : AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread ? AppColors.grey800 : AppColors.grey600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isUnread ? AppColors.textSecondary : AppColors.grey400,
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
