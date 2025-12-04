import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';

final NumberFormat rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: "Rp ",
  decimalDigits: 0,
);

class UploadProdukScreen extends StatefulWidget {
  const UploadProdukScreen({super.key});

  @override
  State<UploadProdukScreen> createState() => _UploadProdukScreenState();
}

class _UploadProdukScreenState extends State<UploadProdukScreen> {
  String? selectedPetani;
  String? selectedKategori;
  String? selectedVarietas;

  final _jumlahController = TextEditingController();
  final _namaProdukController = TextEditingController();
  final _hargaController = TextEditingController();
  final _masaSimpanController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _infoTambahanController = TextEditingController();

  DateTime? tanggalPanen;
  String? masaSimpanNote;

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  final Map<String, int> hpp = {"Gabah": 6500, "Jagung": 5000};
  @override
  void initState() {
    super.initState();

    _hargaController.addListener(() {
      final text = _hargaController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        final formatted = rupiah.format(int.parse(text));
        if (formatted != _hargaController.text) {
          _hargaController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });
  }

  void showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Produk Berhasil Disimpan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Produk sudah berhasil tersimpan!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImages() async {
    if (selectedImages.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maksimal 5 foto")));
      return;
    }

    final picked = await _picker.pickMultiImage();
    if (!mounted) return;

    if (picked.isNotEmpty) {
      if (selectedImages.length + picked.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Total foto tidak boleh lebih dari 5")),
        );
      }

      setState(() {
        selectedImages.addAll(
          picked.take(5 - selectedImages.length).map((e) => File(e.path)),
        );
      });
    }
  }

  Future<void> pilihTanggalPanen() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      tanggalPanen = picked;

      int masa = int.tryParse(_masaSimpanController.text) ?? 0;
      if (masa > 0) {
        DateTime expired = picked.add(Duration(days: masa));
        masaSimpanNote =
            "ℹ️ Masa Simpan $masa hari (s/d ${expired.day} ${_bulan(expired.month)} ${expired.year})";
      }
      setState(() {});
    }
  }

  String _bulan(int m) {
    const b = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return b[m];
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget inputLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        t,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
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
          "Kelola Data Petani",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          sectionCard(
            title: "Foto Produk",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Upload Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),

                if (selectedImages.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedImages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    itemBuilder: (_, i) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImages[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () =>
                                  setState(() => selectedImages.removeAt(i)),
                              child: const CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 12,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),

          sectionCard(
            title: "Informasi Utama",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputLabel("Nama Produk *"),
                TextField(
                  controller: _namaProdukController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                ),
                const SizedBox(height: 14),

                inputLabel("Nama Petani *"),
                DropdownButtonFormField(
                  initialValue: selectedPetani,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: ["Abdul Rahman", "Budi Santoso"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedPetani = v),
                ),
                const SizedBox(height: 14),

                inputLabel("Kategori *"),
                DropdownButtonFormField(
                  initialValue: selectedKategori,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ["Gabah", "Jagung"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedKategori = v;
                      int harga = hpp[selectedKategori]!;
                      _hargaController.text = rupiah.format(harga);
                    });
                  },
                ),

                if (selectedKategori != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "ℹ️ HPP ${selectedKategori!}: Rp ${hpp[selectedKategori]}/kg",
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ),
              ],
            ),
          ),

          sectionCard(
            title: "Detail Produk",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedKategori == "Gabah") ...[
                  inputLabel("Varietas *"),
                  DropdownButtonFormField(
                    initialValue: selectedVarietas,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grass),
                    ),
                    items: ["Ciherang", "Pertiwi"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedVarietas = v),
                  ),
                  const SizedBox(height: 14),
                ],

                inputLabel("Tanggal Panen *"),
                InkWell(
                  onTap: pilihTanggalPanen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 10),
                        Text(
                          tanggalPanen == null
                              ? "Pilih tanggal"
                              : "${tanggalPanen!.day} ${_bulan(tanggalPanen!.month)} ${tanggalPanen!.year}",
                        ),
                      ],
                    ),
                  ),
                ),

                if (masaSimpanNote != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      masaSimpanNote!,
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ),

                const SizedBox(height: 14),

                inputLabel("Harga per Kg *"),
                TextField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.price_change),
                  ),
                ),

                const SizedBox(height: 14),

                inputLabel("Jumlah Stok (kg) *"),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
              ],
            ),
          ),

          sectionCard(
            title: "Lainnya",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputLabel("Lokasi Produk *"),
                TextField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 14),

                inputLabel("Info Tambahan"),
                TextField(
                  maxLines: 3,
                  controller: _infoTambahanController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showSuccessPopup();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "SIMPAN PRODUK",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
