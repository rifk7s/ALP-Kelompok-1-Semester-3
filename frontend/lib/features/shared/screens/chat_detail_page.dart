import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  final String image;

  const ChatDetailPage({super.key, required this.name, required this.image});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _msgController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      "fromMe": false,
      "text":
          "Selamat siang Pak. Kiriman gabahnya tadi sudah sampai. Saya cek satu-satu, dan kualitasnya bagus sekali. Bersih, kering, dan ukuran butirnya juga seragam.",
    },
    {
      "fromMe": true,
      "text":
          "Alhamdulillah, terima kasih juga sudah membantu proses pengecekan.",
      "read": true,
    },
    {
      "fromMe": false,
      "text":
          "Iya sama-sama Pak. Oh iya, untuk pembayaran panen kali ini, apakah bisa dilakukan minggu depan? Saya sedang ada kebutuhan mendesak.",
    },
    {
      "fromMe": true,
      "text":
          "Bisa Pak, tidak masalah. Nanti saya sesuaikan jadwal pembayarannya.",
      "read": true,
    },
    {
      "fromMe": false,
      "text": "Terima kasih banyak Pak, sangat membantu sekali.",
    },
    {
      "fromMe": true,
      "text":
          "Sama-sama Pak. Btw, berapa total berat panen yang dikirim kemarin?",
      "read": true,
    },
    {
      "fromMe": false,
      "text":
          "Sekitar 850 kilogram Pak. Itu sudah saya pisahkan yang kualitas premium dan yang standar.",
    },
    {
      "fromMe": true,
      "text":
          "Baik, nanti saya catat di sistem PanenKu. Paling cepat sore sudah masuk semua datanya.",
      "read": true,
    },
    {
      "fromMe": false,
      "text":
          "Siap Pak. Kalau untuk harga, masih tetap seperti kesepakatan bulan lalu kan?",
    },
    {
      "fromMe": true,
      "text":
          "Iya Pak, masih sama. Tidak ada perubahan harga untuk gabah kualitas premium bulan ini.",
      "read": true,
    },
    {
      "fromMe": false,
      "text":
          "Syukurlah. Soalnya beberapa petani tetangga bilang harga di tempat lain turun.",
    },
    {
      "fromMe": true,
      "text":
          "Betul Pak, banyak yang turun. Tapi PanenKu kita usahakan tetap stabil biar petani tidak rugi.",
      "read": true,
    },
    {
      "fromMe": false,
      "text":
          "Mantap sekali kalau begitu. Terima kasih sudah bantu kami terus Pak.",
    },
    {
      "fromMe": true,
      "text": "Sama-sama Pak. Kalau nanti ada panen tambahan kabari saja ya.",
      "read": true,
    },
    {
      "fromMe": false,
      "text": "Siap Pak. Minggu depan kemungkinan ada tambahan sedikit.",
    },
    {"fromMe": true, "text": "Baik, saya tunggu kabarnya Pak.", "read": true},
  ];

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    scrollToBottom();
  }

  void sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"fromMe": true, "text": text, "read": false});
    });

    _msgController.clear();

    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(widget.image)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Online",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final fromMe = msg["fromMe"];

                return Align(
                  alignment: fromMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: fromMe
                          ? AppColors.chatBubbleSent
                          : AppColors.chatBubbleReceived,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(fromMe ? 18 : 0),
                        bottomRight: Radius.circular(fromMe ? 0 : 18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            msg["text"],
                            style: const TextStyle(fontSize: 15, height: 1.3),
                          ),
                        ),

                        if (fromMe) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.done_all,
                            size: 18,
                            color: msg["read"] == true
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.chatInputBackground,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chatInputField,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 22,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: "Balasan",
                              hintStyle: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: sendMessage,
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
