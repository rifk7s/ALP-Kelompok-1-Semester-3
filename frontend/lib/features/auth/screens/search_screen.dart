import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFFFFFBF0),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,

          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),

                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.black12, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),

                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: "Cari produk...",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: const Center(
        child: Text(
          "Hasil pencarian akan muncul di sini",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
