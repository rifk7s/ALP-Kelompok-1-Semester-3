import 'package:flutter/material.dart';
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
        'name': 'Vivian',
        'message': 'Oke besok saya kirim ya',
        'time': '19.20',
        'image': 'assets/images/logo.png',
      },
      {
        'name': 'Admin PanenKu',
        'message': 'Baik kak, sudah diterima',
        'time': '18.04',
        'image': 'assets/images/logo.png',
      },
      {
        'name': 'Penjual Jagung',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              width: double.infinity,
              color: const Color(0xFFFFFBF0),
              child: Stack(
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
                  const Positioned(
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined),
                        SizedBox(width: 12),
                        Icon(Icons.notifications_outlined),
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
                  : ListView.builder(
                      itemCount: _filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = _filteredChats[index];
                        return chatItem(
                          name: chat['name']!,
                          message: chat['message']!,
                          time: chat['time']!,
                          image: chat['image']!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatItem({
    required String name,
    required String message,
    required String time,
    required String image,
  }) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(radius: 28, backgroundImage: AssetImage(image)),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(message),
          trailing: Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(name: name, image: image),
              ),
            );
          },
        ),

        const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
      ],
    );
  }
}
