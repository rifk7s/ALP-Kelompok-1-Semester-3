import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  List<String> petani = ["Abdul Rahman", "Budi Santoso"];
  List<String> kategori = ["Gabah", "Jagung"];
  List<String> varietasGabah = ["Ciherang", "Pertiwi"];

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
        if (img is File) {
          images.add(img);
        }
      }
    }

    if (selectedPetani != null && !petani.contains(selectedPetani)) {
      petani.add(selectedPetani!);
    }

    if (selectedKategori != null && !kategori.contains(selectedKategori)) {
      kategori.add(selectedKategori!);
    }

    if (selectedVarietas != null && !varietasGabah.contains(selectedVarietas)) {
      varietasGabah.add(selectedVarietas!);
    }
  }

  Future pickImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 70);
    if (!mounted) return;
    if (picked.isNotEmpty) {
      if (images.length + picked.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maksimal 5 foto")),
        );
        return;
      }
      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  int calculateMasaSimpan(DateTime? panen) {
    if (panen == null) return 0;
    return DateTime.now().difference(panen).inDays.abs();
  }

  String getHPP(String? kategori) {
    if (kategori == "Gabah") return "Rp 6.500/kg";
    if (kategori == "Jagung") return "Rp 5.000/kg";
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    final masaSimpan = selectedTanggalPanen != null
        ? calculateMasaSimpan(selectedTanggalPanen!)
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Produk"),
        backgroundColor: Colors.brown,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Foto Produk (max 5)"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              ...images.map((file) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            images.remove(file);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (images.length < 5)
                GestureDetector(
                  onTap: pickImages,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          const Text("⭐ Kontributor Petani: *"),
          DropdownButtonFormField<String>(
            initialValue: selectedPetani,
            items: petani
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => selectedPetani = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          const Text("Jumlah Kontribusi (kg) *"),
          TextField(
            controller: _jumlahController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          const Text("Nama Produk *"),
          TextField(
            controller: _namaProdukController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          const Text("Kategori *"),
          DropdownButtonFormField<String>(
            initialValue: selectedKategori,
            items: kategori
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {
              setState(() {
                selectedKategori = v;
                selectedVarietas = null;
              });
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.info, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                "HPP ${selectedKategori ?? ''}: ${getHPP(selectedKategori)}",
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (selectedKategori == "Gabah") ...[
            const Text("Varietas *"),
            DropdownButtonFormField<String>(
              initialValue: selectedVarietas,
              items: varietasGabah
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedVarietas = v),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
          ],

          const Text("Tanggal Panen *"),
          GestureDetector(
            onTap: () async {
              final result = await showDatePicker(
                context: context,
                initialDate: selectedTanggalPanen ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (result != null) {
                setState(() {
                  selectedTanggalPanen = result;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedTanggalPanen == null
                        ? "Pilih tanggal"
                        : "${selectedTanggalPanen!.day} / ${selectedTanggalPanen!.month} / ${selectedTanggalPanen!.year}",
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text("Auto-calculate: masa simpan $masaSimpan hari"),
            ],
          ),
          const SizedBox(height: 12),

          const Text("Harga per Kg *"),
          TextField(
            controller: _hargaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          const Text("Info Tambahan"),
          TextField(
            controller: _infoTambahanController,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          const Text("Lokasi"),
          TextField(
            controller: _lokasiController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) {
                  return AlertDialog(
                    title: const Text("Berhasil"),
                    content: const Text("Produk berhasil diperbarui"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("SIMPAN PERUBAHAN"),
          ),
        ],
      ),
    );
  }
}
