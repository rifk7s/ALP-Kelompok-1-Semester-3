import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'chat_bumdes_screen.dart';

class ContactBumdesPage extends StatefulWidget {
  const ContactBumdesPage({super.key});

  @override
  State<ContactBumdesPage> createState() => _ContactBumdesPageState();
}

class _ContactBumdesPageState extends State<ContactBumdesPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, String>> _allChats;
  late List<Map<String, String>> _filteredChats;

  @override
  void initState() {
    super.initState();
    _allChats = [
      {
        'name': 'Pembeli 1',
        'message': 'Oke besok saya kirim ya',
        'time': '19.20',
        'image': 'assets/images/logo.png',
      },
      {
        'name': 'Pembeli 2',
        'message': 'Baik kak, sudah diterima',
        'time': '18.04',
        'image': 'assets/images/logo.png',
      },
      {
        'name': 'Pembeli 3',
        'message': 'Siap ditunggu',
        'time': '16.55',
        'image': 'assets/images/logo.png',
      },
    ];
    _filteredChats = List.from(_allChats);

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredChats = List.from(_allChats);
      } else {
        _filteredChats = _allChats.where((chat) {
          final name = chat['name']!.toLowerCase();
          final message = chat['message']!.toLowerCase();
          return name.contains(q) || message.contains(q);
        }).toList();
      }
    });
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationPage(),
                              ),
                            );
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
                onChanged: _filterChats,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterChats('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            Expanded(
              child: _filteredChats.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada chat',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredChats.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFEDEDED),
                      ),
                      itemBuilder: (context, index) {
                        final chat = _filteredChats[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: AssetImage(chat['image']!),
                          ),
                          title: Text(
                            chat['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(chat['message']!),
                          trailing: Text(
                            chat['time']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatBumdesPage(
                                  name: chat['name']!,
                                  image: chat['image']!,
                                ),
                              ),
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
