import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:intl/intl.dart';

class ContactBumdesPage extends StatefulWidget {
  const ContactBumdesPage({super.key});

  @override
  State<ContactBumdesPage> createState() => _ContactBumdesPageState();
}

class _ContactBumdesPageState extends State<ContactBumdesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _currentUserId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    await ChatService.signInToFirebase();
    if (mounted) {
      setState(() {
        _currentUserId = ChatService.getCurrentUserId();
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return DateFormat('HH.mm').format(date);
    }
    return DateFormat('dd/MM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: AppColors.surface,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Pesan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            context.push(RoutePaths.notifications);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            Expanded(
              child: !_isInitialized
                  ? const Center(child: AppLoadingIndicator())
                  : _currentUserId == null
                  ? const Center(
                      child: Text(
                        'Silakan masuk untuk melihat pesan',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: ChatService.getChatRooms(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: AppLoadingIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Belum ada chat',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          );
                        }

                        final chats = snapshot.data!.docs.where((doc) {
                          if (_searchQuery.isEmpty) return true;
                          final data = doc.data() as Map<String, dynamic>;
                          final names =
                              data['participantNames']
                                  as Map<String, dynamic>? ??
                              {};
                          final otherName = names.entries
                              .firstWhere(
                                (e) => e.key != _currentUserId,
                                orElse: () => MapEntry('', ''),
                              )
                              .value
                              .toString()
                              .toLowerCase();
                          return otherName.contains(_searchQuery);
                        }).toList();

                        if (chats.isEmpty) {
                          return const Center(
                            child: Text(
                              'Tidak ada chat ditemukan',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: chats.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.divider,
                          ),
                          itemBuilder: (context, index) {
                            final doc = chats[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final names =
                                data['participantNames']
                                    as Map<String, dynamic>? ??
                                {};
                            final images =
                                data['participantImages']
                                    as Map<String, dynamic>? ??
                                {};
                            final participants = List<String>.from(
                              data['participants'] ?? [],
                            );

                            final otherUserId = participants.firstWhere(
                              (id) => id != _currentUserId,
                              orElse: () => '',
                            );
                            final otherName = names[otherUserId] ?? 'Pengguna';
                            final otherImage = images[otherUserId] ?? '';
                            final lastMessage = data['lastMessage'] ?? '';
                            final lastTime =
                                data['lastMessageTime'] as Timestamp?;
                            final unreadCounts =
                                (data['unreadCounts']
                                    as Map<String, dynamic>? ??
                                {});
                            final unread =
                                (unreadCounts[_currentUserId] ?? 0) as int;

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    otherImage.isNotEmpty &&
                                        !otherImage.startsWith('assets/')
                                    ? NetworkImage(otherImage)
                                    : const AssetImage('assets/images/logo.png')
                                          as ImageProvider,
                              ),
                              title: Text(
                                otherName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatTime(lastTime),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  if (unread > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        unread > 99 ? '99+' : unread.toString(),
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                context.push(
                                  RoutePaths.chat,
                                  extra: {
                                    'chatId': doc.id,
                                    'name': otherName,
                                    'image': otherImage.isNotEmpty
                                        ? otherImage
                                        : 'assets/images/logo.png',
                                    'recipientId': otherUserId,
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
