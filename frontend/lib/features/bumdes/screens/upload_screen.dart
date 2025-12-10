import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/category_service.dart';
import 'package:frontend/core/services/hpp_price_service.dart';
import 'package:frontend/core/services/petani_service.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/storage_service.dart';

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
  int? selectedPetaniId;
  String? selectedKategori;
  int? selectedKategoriId;
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

  // Data from backend
  List<dynamic> categories = [];
  List<PetaniData> petaniList = [];
  List<dynamic> hppPrices = [];
  Map<String, List<String>> varietiesByCategory = {};
  
  bool isLoading = true;
  bool isSubmitting = false;
  @override
  void initState() {
    super.initState();
    loadData();

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

  Future<void> loadData() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Load categories
      final categoriesData = await CategoryService.getCategories();
      print('Categories loaded: ${categoriesData.length}');
      
      // Load petani data
      final petaniData = await PetaniService().fetchAllPetani(token: token);
      print('Petani loaded: ${petaniData.length}');
      
      // Load HPP prices
      final hppData = await HppPriceService.getHppPrices();
      print('HPP prices loaded: ${hppData.length}');

      // Group varieties by category
      Map<String, List<String>> varieties = {};
      for (var hpp in hppData) {
        String categoryName = hpp['category']['name'];
        String variety = hpp['variety'];
        
        if (!varieties.containsKey(categoryName)) {
          varieties[categoryName] = [];
        }
        if (!varieties[categoryName]!.contains(variety)) {
          varieties[categoryName]!.add(variety);
        }
      }

      setState(() {
        categories = categoriesData;
        petaniList = petaniData;
        hppPrices = hppData;
        varietiesByCategory = varieties;
        isLoading = false;
      });
      
      print('Data loaded successfully!');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  double? getPriceForSelection() {
    if (selectedKategoriId == null) return null;
    
    for (var hpp in hppPrices) {
      if (hpp['category_id'] == selectedKategoriId) {
        // Check if variety matches (for categories with varieties like Gabah)
        if (selectedVarietas != null && hpp['variety'] == selectedVarietas) {
          return double.parse(hpp['price_per_kg'].toString());
        }
        // For categories without specific varieties or if no variety selected yet
        if (selectedVarietas == null) {
          return double.parse(hpp['price_per_kg'].toString());
        }
      }
    }
    return null;
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

  Future<void> submitProduct() async {
    // Validation
    if (_namaProdukController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama produk harus diisi')),
      );
      return;
    }

    if (selectedPetaniId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih petani terlebih dahulu')),
      );
      return;
    }

    if (selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    if (tanggalPanen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal panen')),
      );
      return;
    }

    if (_jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah stok harus diisi')),
      );
      return;
    }

    final price = getPriceForSelection();
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga tidak ditemukan')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Determine variety - use selected variety or "Standard" if none
      String variety = selectedVarietas ?? 'Standard';
      
      // Parse storage days, default to 0 if empty
      int storageDays = int.tryParse(_masaSimpanController.text) ?? 0;

      await ProductService.createProduct(
        name: _namaProdukController.text,
        categoryId: selectedKategoriId!,
        variety: variety,
        harvestDate: tanggalPanen!.toIso8601String().split('T')[0],
        storageDays: storageDays,
        pricePerKg: price,
        stockKg: double.parse(_jumlahController.text),
        description: _infoTambahanController.text.isEmpty 
            ? null 
            : _infoTambahanController.text,
        petaniId: selectedPetaniId,
        images: selectedImages.isEmpty ? null : selectedImages,
      );

      setState(() {
        isSubmitting = false;
      });

      showSuccessPopup();
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
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
    if (isLoading) {
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
              color: AppColors.textLight,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state if data failed to load
    if (categories.isEmpty || hppPrices.isEmpty) {
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
              color: AppColors.textLight,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Silakan coba lagi'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  loadData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            color: AppColors.textLight,
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
                DropdownButtonFormField<int>(
                  value: selectedPetaniId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: petaniList
                      .where((p) => p.isActive)
                      .map((p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedPetaniId = v;
                      final petani = petaniList.firstWhere((p) => p.id == v);
                      selectedPetani = petani.name;
                    });
                  },
                ),
                const SizedBox(height: 14),

                inputLabel("Kategori *"),
                DropdownButtonFormField<int>(
                  value: selectedKategoriId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem<int>(
                            value: c['id'],
                            child: Text(c['name']),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedKategoriId = v;
                      final category = categories.firstWhere((c) => c['id'] == v);
                      selectedKategori = category['name'];
                      selectedVarietas = null; // Reset variety
                      
                      // Update price based on category
                      final price = getPriceForSelection();
                      if (price != null) {
                        _hargaController.text = rupiah.format(price.toInt());
                      }
                    });
                  },
                ),

                if (selectedKategori != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "ℹ️ HPP ${selectedKategori!}: Rp ${(getPriceForSelection() ?? 0).toInt()}/kg",
                      style: const TextStyle(color: AppColors.textDark),
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
                if (selectedKategori != null && 
                    varietiesByCategory.containsKey(selectedKategori) &&
                    varietiesByCategory[selectedKategori]!.length > 1) ...[
                  inputLabel("Varietas *"),
                  DropdownButtonFormField<String>(
                    value: selectedVarietas,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grass),
                    ),
                    items: varietiesByCategory[selectedKategori]!
                        .map((v) => DropdownMenuItem<String>(
                              value: v,
                              child: Text(v),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedVarietas = v;
                        // Update price based on variety
                        final price = getPriceForSelection();
                        if (price != null) {
                          _hargaController.text = rupiah.format(price.toInt());
                        }
                      });
                    },
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
                      border: Border.all(color: AppColors.border),
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
                      style: const TextStyle(color: AppColors.textDark),
                    ),
                  ),

                const SizedBox(height: 14),

                inputLabel("Harga per Kg *"),
                TextField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.price_change),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  style: const TextStyle(
                    color: Colors.black54,
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
              onPressed: isSubmitting ? null : submitProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
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
