import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/notification_screen.dart';
import 'package:frontend/features/auth/screens/transaction/cart_screen.dart';
import 'chat_detail_page.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
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
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: const Color(0xFFFFFBF0),
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
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartPage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationPage(),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterChats,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Cari",
                    border: InputBorder.none,
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
            ),

            Expanded(
              child: _filteredChats.isEmpty
                  ? Center(
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
                                builder: (context) => ChatDetailPage(
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
