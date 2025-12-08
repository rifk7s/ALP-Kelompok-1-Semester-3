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

class EditProdukScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditProdukScreen({super.key, required this.data});

  @override
  State<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  String? selectedPetani;
  String? selectedKategori;
  String? selectedVarietas;
  DateTime? selectedTanggalPanen;

  final _jumlahController = TextEditingController();
  final _namaProdukController = TextEditingController();
  final _hargaController = TextEditingController();
  final _masaSimpanController = TextEditingController();
  final _infoTambahanController = TextEditingController();
  final _lokasiController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  List<File> images = [];

  final Map<String, int> hpp = {"Gabah": 6500, "Jagung": 5000};
  final List<String> petaniList = [
    "Abdul Rahman",
    "Budi Santoso",
    "Pak Jono",
    "Bu Rani",
  ];
  final List<String> varietasGabah = ["Ciherang", "Pertiwi"];

  @override
  void initState() {
    super.initState();

    selectedPetani = widget.data['petani'];
    selectedKategori = widget.data['kategori'];
    selectedVarietas = widget.data['varietas'];
    selectedTanggalPanen = widget.data['tanggalPanen'];

    _jumlahController.text = widget.data['jumlah'] ?? "";
    _namaProdukController.text = widget.data['nama'] ?? "";
    _hargaController.text = widget.data['harga'] ?? "";
    _masaSimpanController.text = widget.data['masaSimpan'] ?? "";
    _infoTambahanController.text = widget.data['info'] ?? "";
    _lokasiController.text = widget.data['lokasi'] ?? "";

    if (widget.data['images'] != null) {
      for (var img in widget.data['images']) {
        if (img is File) images.add(img);
      }
    }
  }

  Future pickImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 70);

    if (!mounted) return;

    if (picked.isNotEmpty) {
      if (images.length + picked.length > 5) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Maksimal 5 foto")));
        return;
      }

      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 2)),
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

  void showSavedPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Produk Diperbarui",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Perubahan produk berhasil disimpan."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Edit Produk",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FOTO PRODUK
          sectionCard(
            title: "Foto Produk",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Tambah Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),

                if (images.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (_, i) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(images[i], fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () => setState(() => images.removeAt(i)),
                              child: const CircleAvatar(
                                backgroundColor: AppColors.textMuted,
                                radius: 12,
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.white,
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

          // INFORMASI UTAMA
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

                inputLabel("Kontributor Petani *"),
                DropdownButtonFormField(
                  initialValue: selectedPetani,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: petaniList
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
                      _hargaController.text = rupiah.format(
                        hpp[selectedKategori]!,
                      );
                    });
                  },
                ),

                if (selectedKategori != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "ℹ️ HPP ${selectedKategori!}: Rp ${hpp[selectedKategori]}/kg",
                      style: const TextStyle(color: AppColors.blueGrey),
                    ),
                  ),
              ],
            ),
          ),

          // DETAIL PRODUK
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
                    items: varietasGabah
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedVarietas = v),
                  ),
                  const SizedBox(height: 14),
                ],

                inputLabel("Tanggal Panen *"),
                InkWell(
                  onTap: () async {
                    final result = await showDatePicker(
                      context: context,
                      initialDate: selectedTanggalPanen ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );

                    if (result != null) {
                      setState(() => selectedTanggalPanen = result);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 10),
                        Text(
                          selectedTanggalPanen == null
                              ? "Pilih tanggal"
                              : "${selectedTanggalPanen!.day}/${selectedTanggalPanen!.month}/${selectedTanggalPanen!.year}",
                        ),
                      ],
                    ),
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

          // LAINNYA
          sectionCard(
            title: "Lainnya",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputLabel("Lokasi Produk"),
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

          // TOMBOL SIMPAN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: showSavedPopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "SIMPAN PERUBAHAN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
