import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/chat_detail_page.dart';
import 'package:frontend/features/auth/screens/transaction/cart_screen.dart';

class ProductDetailPage extends StatefulWidget {
  final String name;
  final String price;
  final String stock;
  final String image;
  final String sellerName;
  final String location;
  final String category;
  final String variety;
  final String harvestDate;
  final String description;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
    required this.sellerName,
    required this.location,
    required this.category,
    required this.variety,
    required this.harvestDate,
    required this.description,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int tempQty = 1;

  int get parsedPrice {
    final numeric = widget.price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numeric) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 14),
              _productImage(),
              const SizedBox(height: 20),
              _productNameAndPrice(),
              const SizedBox(height: 14),
              _stockLabel(),
              const SizedBox(height: 20),
              _sellerCard(),

              const SizedBox(height: 28),
              SectionCard(
                title: "Spesifikasi Produk",
                children: [
                  InfoRow(
                    icon: Icons.category_outlined,
                    label: "Kategori",
                    value: widget.category,
                  ),
                  InfoRow(
                    icon: Icons.qr_code_2_outlined,
                    label: "Varietas",
                    value: widget.variety,
                  ),
                  InfoRow(
                    icon: Icons.date_range_outlined,
                    label: "Tanggal Panen",
                    value: widget.harvestDate,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SectionCard(
                title: "Info Tambahan",
                children: [
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Detail Produk",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _productImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        widget.image,
        height: 230,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _productNameAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          widget.price,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _stockLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF8A6B4F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Tersedia: ${widget.stock}",
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _sellerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.brown.withValues(alpha: 0.08), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/images/profile.png"),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sellerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.location,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatDetailPage(name: widget.name, image: widget.image),
                ),
              );
            },
            child: const Icon(Icons.chat_bubble_outline, color: Colors.brown),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _openQtyDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A6B4F),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "+ Keranjang",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _openQtyDialog() {
    tempQty = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            int total = parsedPrice * tempQty;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        widget.image,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _qtyButton(Icons.remove, () {
                          if (tempQty > 1) {
                            setStateDialog(() => tempQty--);
                          }
                        }),
                        GestureDetector(
                          onTap: () {
                            _showQtyInputDialog(context, tempQty, (newQty) {
                              setStateDialog(() => tempQty = newQty);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.brown.shade200),
                            ),
                            child: Text(
                              tempQty.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        _qtyButton(Icons.add, () {
                          setStateDialog(() => tempQty++);
                        }),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Total: Rp ${total.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.brown.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Batal",
                              style: TextStyle(
                                color: Colors.brown.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Berhasil!"),
                                  content: Text(
                                    "${widget.name} × $tempQty ditambahkan ke keranjang.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const CartPage(),
                                          ),
                                        );
                                      },
                                      child: const Text("Lihat Keranjang"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A6B4F),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Tambah",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showQtyInputDialog(BuildContext context, int currentQty, Function(int) onConfirm) {
    final controller = TextEditingController(text: currentQty.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            "Masukkan Jumlah",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Jumlah",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF8A6B4F), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(color: Colors.brown.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(controller.text) ?? 1;
                final qty = input < 1 ? 1 : input;
                Navigator.pop(context);
                onConfirm(qty);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A6B4F),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF8A6B4F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.brown.withValues(alpha: 0.08), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.brown.shade600),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
