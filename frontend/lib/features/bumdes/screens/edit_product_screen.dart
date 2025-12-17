import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/services/api_config.dart';
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

class EditProdukScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProdukScreen({super.key, required this.product});

  @override
  State<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  // Multiple petani contributors
  List<Map<String, dynamic>> petaniContributors = [];
  int? selectedPetaniId; // For dropdown
  String? selectedPetani; // For dropdown
  final _kontribusiController = TextEditingController();
  DateTime? selectedHarvestDate; // For contributor harvest date

  String? selectedKategori;
  int? selectedKategoriId;
  String? selectedVarietas;

  final _jumlahController = TextEditingController();
  final _namaProdukController = TextEditingController();
  final _hargaController = TextEditingController();
  final _masaSimpanController = TextEditingController();
  final _infoTambahanController = TextEditingController();

  DateTime? tanggalPanen;
  String? masaSimpanNote;

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];
  List<Map<String, dynamic>> existingImages = []; // Images from database
  List<int> imagesToDelete = []; // IDs of images to delete

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
    _jumlahController.text = '0.00'; // Initialize with 0
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
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      // Load categories
      final categoriesData = await CategoryService.getCategories();

      // Load petani data
      final petaniData = await PetaniService().fetchAllPetani(token: token);

      // Load HPP prices
      final hppData = await HppPriceService.getHppPrices();

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

        // Populate form with existing product data
        _namaProdukController.text = widget.product['name'] ?? '';
        _jumlahController.text = widget.product['stock_kg']?.toString() ?? '';
        _masaSimpanController.text =
            widget.product['storage_days']?.toString() ?? '';
        _infoTambahanController.text = widget.product['description'] ?? '';

        // Set category
        if (widget.product['category_id'] != null) {
          selectedKategoriId = widget.product['category_id'];
          final category = categories.firstWhere(
            (c) => c['id'] == selectedKategoriId,
            orElse: () => {},
          );
          if (category.isNotEmpty) {
            selectedKategori = category['name'];
          }
        }

        // Set variety
        selectedVarietas = widget.product['variety'];

        // Set harvest date
        if (widget.product['harvest_date'] != null) {
          tanggalPanen = DateTime.parse(widget.product['harvest_date']);
        }

        // Set price
        final price = getPriceForSelection();
        if (price != null) {
          _hargaController.text = rupiah.format(price.toInt());
        }

        // Load all contributors from product contributions
        if (widget.product['product_contributions'] != null) {
          final contributions = widget.product['product_contributions'] as List;
          petaniContributors = contributions
              .map(
                (contrib) => {
                  'petani_id': contrib['petani']['id'],
                  'petani_name': contrib['petani']['name'],
                  'contributed_kg': double.parse(
                    contrib['contributed_kg'].toString(),
                  ),
                  'harvest_date':
                      contrib['harvest_date'] ??
                      DateTime.now().toIso8601String().split('T')[0],
                },
              )
              .toList()
              .cast<Map<String, dynamic>>();

          // Calculate total stock from contributions
          final total = petaniContributors.fold<double>(
            0,
            (sum, c) => sum + (c['contributed_kg'] as num).toDouble(),
          );
          _jumlahController.text = total.toStringAsFixed(2);
        }

        // Load existing images
        if (widget.product['product_images'] != null) {
          existingImages = List<Map<String, dynamic>>.from(
            widget.product['product_images'].map(
              (img) => {'id': img['id'], 'image_path': img['image_path']},
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
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

  Future<void> submitUpdate() async {
    if (isSubmitting) return;

    // Validation
    if (_namaProdukController.text.isEmpty) {
      SnackBarHelper.showError(context, 'Nama produk harus diisi');
      return;
    }

    if (petaniContributors.isEmpty) {
      SnackBarHelper.showError(
        context,
        'Tambahkan minimal 1 kontributor petani',
      );
      return;
    }

    // Validate total contributions match stock
    final totalContributions = petaniContributors.fold<double>(
      0,
      (sum, contrib) => sum + (contrib['contributed_kg'] as num).toDouble(),
    );
    final stockKg =
        double.tryParse(_jumlahController.text.replaceAll(',', '.')) ?? 0;
    if (stockKg > 0 && (totalContributions - stockKg).abs() > 0.01) {
      SnackBarHelper.showError(
        context,
        'Total kontribusi (${totalContributions.toStringAsFixed(2)} kg) harus sama dengan stok (${stockKg.toStringAsFixed(2)} kg)',
      );
      return;
    }

    if (selectedKategoriId == null) {
      SnackBarHelper.showError(context, 'Pilih kategori terlebih dahulu');
      return;
    }

    if (tanggalPanen == null) {
      SnackBarHelper.showError(context, 'Pilih tanggal panen');
      return;
    }

    if (_jumlahController.text.isEmpty || stockKg <= 0) {
      SnackBarHelper.showError(
        context,
        'Jumlah stok harus diisi dan lebih dari 0',
      );
      return;
    }

    final price = getPriceForSelection();
    if (price == null) {
      SnackBarHelper.showError(context, 'Harga tidak ditemukan');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Determine variety - use selected variety or "Standard" if none
      String variety = selectedVarietas ?? 'Standard';

      // Parse storage days, default to 0 if empty
      int storageDays = int.tryParse(_masaSimpanController.text) ?? 0;

      final response = await ProductService.updateProduct(
        productId: widget.product['id'],
        token: token,
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
        petaniContributors: petaniContributors,
        newImages: selectedImages.isNotEmpty ? selectedImages : null,
        imageIdsToDelete: imagesToDelete.isNotEmpty ? imagesToDelete : null,
      );

      setState(() {
        isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Return the updated product
        Navigator.pop(context, response['product']);
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
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

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      return '${date.day} ${_bulan(date.month)} ${date.year}';
    } catch (e) {
      return '-';
    }
  }

  Future<void> _editContributor(int index, Map<String, dynamic> contrib) async {
    final TextEditingController editKgController = TextEditingController(
      text: contrib['contributed_kg'].toString(),
    );
    int? editPetaniId = contrib['petani_id'];
    String? editPetaniName = contrib['petani_name'];
    DateTime? editHarvestDate;

    // Parse harvest date
    try {
      editHarvestDate = DateTime.parse(contrib['harvest_date']);
    } catch (e) {
      editHarvestDate = DateTime.now();
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Kontributor'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Harvest date picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: editHarvestDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            editHarvestDate = picked;
                          });
                        }
                      },
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
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              editHarvestDate == null
                                  ? "Pilih tanggal panen"
                                  : "${editHarvestDate!.day} ${_bulan(editHarvestDate!.month)} ${editHarvestDate!.year}",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Petani dropdown
                    DropdownButtonFormField<int>(
                      initialValue: editPetaniId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Petani',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: petaniList
                          .where((p) => p.isActive)
                          .map(
                            (p) => DropdownMenuItem<int>(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          editPetaniId = v;
                          if (v != null) {
                            final petani = petaniList.firstWhere(
                              (p) => p.id == v,
                            );
                            editPetaniName = petani.name;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Kg input
                    TextField(
                      controller: editKgController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Jumlah (kg)',
                        prefixIcon: Icon(Icons.scale),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final kg = double.tryParse(editKgController.text);
                    if (kg == null || kg <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Masukkan jumlah kg yang valid'),
                        ),
                      );
                      return;
                    }
                    if (editPetaniId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih petani')),
                      );
                      return;
                    }
                    if (editHarvestDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih tanggal panen')),
                      );
                      return;
                    }

                    Navigator.pop(context, {
                      'petani_id': editPetaniId!,
                      'petani_name': editPetaniName!,
                      'contributed_kg': kg,
                      'harvest_date': editHarvestDate!.toIso8601String().split(
                        'T',
                      )[0],
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        petaniContributors[index] = result;
        // Update total stock
        final total = petaniContributors.fold<double>(
          0,
          (sum, c) => sum + (c['contributed_kg'] as num).toDouble(),
        );
        _jumlahController.text = total.toStringAsFixed(2);
      });
    }
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
        body: const Center(child: CircularProgressIndicator()),
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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.danger,
              ),
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
                  label: const Text("Tambah Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),

                // Display existing images from database
                if (existingImages.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: existingImages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                    itemBuilder: (_, i) {
                      final image = existingImages[i];
                      final isMarkedForDeletion = imagesToDelete.contains(
                        image['id'],
                      );

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Opacity(
                              opacity: isMarkedForDeletion ? 0.3 : 1.0,
                              child: Image.network(
                                ApiConfig.getImageUrl(image['image_path']),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.greyLight,
                                    child: const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isMarkedForDeletion) {
                                    imagesToDelete.remove(image['id']);
                                  } else {
                                    imagesToDelete.add(image['id']);
                                  }
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: isMarkedForDeletion
                                    ? AppColors.warning
                                    : AppColors.textMuted,
                                radius: 12,
                                child: Icon(
                                  isMarkedForDeletion
                                      ? Icons.undo
                                      : Icons.close,
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

                // Display newly selected images
                if (selectedImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                      itemBuilder: (_, i) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImages[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
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
                            Positioned(
                              left: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

                inputLabel("Kontributor Petani *"),

                // Display added contributors
                if (petaniContributors.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Urutan FIFO (teratas dijual pertama):',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...petaniContributors.asMap().entries.map((entry) {
                          final index = entry.key;
                          final contrib = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contrib['petani_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${contrib['contributed_kg']} kg',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        'Panen: ${_formatDate(contrib['harvest_date'])}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _editContributor(index, contrib);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.danger,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      petaniContributors.removeAt(index);
                                      // Update total stock
                                      final total = petaniContributors
                                          .fold<double>(
                                            0,
                                            (sum, c) =>
                                                sum +
                                                (c['contributed_kg'] as num)
                                                    .toDouble(),
                                          );
                                      _jumlahController.text = total
                                          .toStringAsFixed(2);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${petaniContributors.fold<double>(0, (sum, c) => sum + (c['contributed_kg'] as num).toDouble()).toStringAsFixed(2)} kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Add new contributor
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Harvest date picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedHarvestDate = picked;
                          });
                        }
                      },
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
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              selectedHarvestDate == null
                                  ? "Pilih tanggal panen"
                                  : "${selectedHarvestDate!.day} ${_bulan(selectedHarvestDate!.month)} ${selectedHarvestDate!.year}",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Petani, kg, and add button row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedPetaniId,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                              hintText: 'Pilih Petani',
                            ),
                            items: petaniList
                                .where((p) => p.isActive)
                                .map(
                                  (p) => DropdownMenuItem<int>(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedPetaniId = v;
                                if (v != null) {
                                  final petani = petaniList.firstWhere(
                                    (p) => p.id == v,
                                  );
                                  selectedPetani = petani.name;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _kontribusiController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'kg',
                              prefixIcon: Icon(Icons.scale),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedPetaniId == null) {
                                SnackBarHelper.showError(
                                  context,
                                  'Pilih petani terlebih dahulu',
                                );
                                return;
                              }

                              if (selectedHarvestDate == null) {
                                SnackBarHelper.showError(
                                  context,
                                  'Pilih tanggal panen',
                                );
                                return;
                              }

                              final kg = double.tryParse(
                                _kontribusiController.text,
                              );
                              if (kg == null || kg <= 0) {
                                SnackBarHelper.showError(
                                  context,
                                  'Masukkan jumlah kg yang valid',
                                );
                                return;
                              }

                              setState(() {
                                petaniContributors.add({
                                  'petani_id': selectedPetaniId!,
                                  'petani_name': selectedPetani!,
                                  'contributed_kg': kg,
                                  'harvest_date': selectedHarvestDate!
                                      .toIso8601String()
                                      .split('T')[0],
                                });

                                // Update total stock
                                final total = petaniContributors.fold<double>(
                                  0,
                                  (sum, contrib) =>
                                      sum +
                                      (contrib['contributed_kg'] as num)
                                          .toDouble(),
                                );
                                _jumlahController.text = total.toStringAsFixed(
                                  2,
                                );

                                // Reset fields
                                selectedPetaniId = null;
                                selectedPetani = null;
                                selectedHarvestDate = null;
                                _kontribusiController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                inputLabel("Kategori *"),
                DropdownButtonFormField<int>(
                  initialValue: selectedKategoriId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c['id'],
                          child: Text(c['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedKategoriId = v;
                      final category = categories.firstWhere(
                        (c) => c['id'] == v,
                      );
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

                if (selectedKategori != null && getPriceForSelection() != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "ℹ️ HPP $selectedKategori: Rp ${getPriceForSelection()!.toInt()}/kg",
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
                    initialValue: selectedVarietas,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grass),
                    ),
                    items: varietiesByCategory[selectedKategori]!
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(v),
                          ),
                        )
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
                    fillColor: AppColors.grey100,
                  ),
                  style: const TextStyle(color: AppColors.textMuted),
                ),

                const SizedBox(height: 14),

                inputLabel("Jumlah Stok (kg) *"),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    filled: true,
                    fillColor: AppColors.grey100,
                    hintText: 'Auto-calculated from contributions',
                  ),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          sectionCard(
            title: "Lainnya",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              onPressed: isSubmitting ? null : submitUpdate,
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
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "SIMPAN PERUBAHAN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
