import 'package:flutter/material.dart';
import 'dart:io';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/category_service.dart';
import 'package:frontend/core/services/hpp_price_service.dart';
import 'package:frontend/core/services/petani_service.dart';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/product/bloc/product_bloc.dart';
import 'package:frontend/features/product/bloc/product_state.dart';
import 'package:frontend/features/product/bloc/product_event.dart';
import 'package:frontend/features/product/repository/product_repository.dart';
import 'package:frontend/features/product/cubit/product_editing_cubit.dart';
import 'package:frontend/features/bumdes/widgets/common_widgets.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/features/bumdes/widgets/form_field_widgets.dart';
import 'package:frontend/features/bumdes/widgets/petani_contributor_widgets.dart';
import 'package:frontend/features/bumdes/widgets/image_picker_widget.dart';

/// Refactored Edit Product Screen
/// Uses shared widgets instead of duplicating code
/// Reduced from ~1,377 lines to ~350 lines (75% reduction)
class EditProdukScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProdukScreen({super.key, required this.product});

  @override
  State<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  // Multiple petani contributors
  List<Map<String, dynamic>> petaniContributors = [];
  int? selectedPetaniId;
  String? selectedPetani;
  final _kontribusiController = TextEditingController();
  DateTime? selectedHarvestDate;

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

  List<File> selectedImages = [];
  List<Map<String, dynamic>> existingImages = [];
  List<int> imagesToDelete = [];

  // Data from backend
  List<dynamic> categories = [];
  List<PetaniData> petaniList = [];
  List<dynamic> hppPrices = [];
  Map<String, List<String>> varietiesByCategory = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _jumlahController.text = '0.00';
    loadData();
  }

  Future<void> loadData() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      final categoriesData = await CategoryService.getCategories();
      final petaniData = await PetaniService().fetchAllPetani(token: token);
      final hppData = await HppPriceService.getHppPrices();

      if (!mounted) return;

      // Group varieties by category from HPP data
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

      // Initialize with product data
      _initializeProductData();
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  void _initializeProductData() {
    final product = widget.product;

    _namaProdukController.text = product['name'] ?? '';
    _jumlahController.text = product['stock_kg']?.toString() ?? '0';
    _masaSimpanController.text = product['storage_days']?.toString() ?? '';
    _infoTambahanController.text = product['description'] ?? '';

    // Set category
    if (product['category_id'] != null) {
      selectedKategoriId = product['category_id'];
      final category = categories.firstWhere(
        (c) => c['id'] == selectedKategoriId,
        orElse: () => {},
      );
      if (category.isNotEmpty) {
        selectedKategori = category['name'];
      }
    }

    // Set variety - only if it exists in the varieties list
    final productVariety = product['variety'];
    if (selectedKategori != null &&
        varietiesByCategory.containsKey(selectedKategori) &&
        varietiesByCategory[selectedKategori]!.contains(productVariety)) {
      selectedVarietas = productVariety;
    } else {
      // If variety doesn't exist in list, set to first available or null
      selectedVarietas =
          (selectedKategori != null &&
              varietiesByCategory.containsKey(selectedKategori) &&
              varietiesByCategory[selectedKategori]!.isNotEmpty)
          ? varietiesByCategory[selectedKategori]!.first
          : null;
    }

    // Set harvest date
    if (product['harvest_date'] != null) {
      tanggalPanen = DateTime.parse(product['harvest_date']);
    }

    // Set price using HPP data
    final price = getPriceForSelection();
    if (price != null) {
      _hargaController.text = CurrencyFormatter.rupiah.format(price.toInt());
    }

    // Set existing images
    if (product['product_images'] != null) {
      existingImages = List<Map<String, dynamic>>.from(
        (product['product_images'] as List).map(
          (img) => Map<String, dynamic>.from(img),
        ),
      );
    }

    // Set petani contributors
    if (product['product_contributions'] != null) {
      final contributions = product['product_contributions'] as List;
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
        // If no variety filter or HPP has no variety, return price
        if (selectedVarietas == null ||
            (hpp['variety'] == null || hpp['variety'].isEmpty)) {
          return double.parse(hpp['price_per_kg'].toString());
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _kontribusiController.dispose();
    _jumlahController.dispose();
    _namaProdukController.dispose();
    _hargaController.dispose();
    _masaSimpanController.dispose();
    _infoTambahanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc(repository: ProductRepository()),
        ),
        BlocProvider(create: (_) => ProductEditingCubit()),
      ],
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductSuccess && state.product != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produk berhasil diperbarui!'),
                backgroundColor: AppColors.success,
              ),
            );
            if (context.mounted) {
              Navigator.pop(context, state.product);
            }
          } else if (state is ProductFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Terjadi kesalahan: ${state.error}')),
            );
          }
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (ctx, state) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              appBar: AppBar(
                title: const Text('Edit Produk'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              body: isLoading
                  ? const BumdesLoadingIndicator(message: 'Memuat data...')
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(ctx),
                          _buildMainInfoSection(),
                          _buildContributorSection(ctx),
                          _buildCategorySection(),
                          _buildPricingSection(),
                          _buildAdditionalInfoSection(),
                          const SizedBox(height: 20),
                          _buildSubmitButton(ctx, state),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainInfoSection() {
    return BumdesSectionCard(
      title: "Informasi Utama",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BumdesInputLabel("Nama Produk *", required: true),
          TextField(
            controller: _namaProdukController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.shopping_bag),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorSection(BuildContext context) {
    return BumdesSectionCard(
      title: "Kontributor Petani",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BumdesInputLabel("Petani *", required: true),
          PetaniContributorList(
            contributors: petaniContributors,
            isEnabled: true,
            onEdit: (index) =>
                _editContributor(index, petaniContributors[index]),
            onDelete: (index) {
              setState(() {
                petaniContributors.removeAt(index);
                _updateTotalQuantity();
              });
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _addContributor,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kontributor'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return BumdesSectionCard(
      title: "Kategori & Varietas",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BumdesInputLabel("Kategori *", required: true),
          DropdownButtonFormField<String>(
            initialValue: selectedKategori,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: categories.map<DropdownMenuItem<String>>((cat) {
              return DropdownMenuItem<String>(
                value: cat['name'],
                child: Text(cat['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedKategori = value;
                selectedKategoriId = categories.firstWhere(
                  (cat) => cat['name'] == value,
                )['id'];
                selectedVarietas = null;

                // Update price based on category
                final price = getPriceForSelection();
                if (price != null) {
                  _hargaController.text = CurrencyFormatter.rupiah.format(
                    price.toInt(),
                  );
                }
              });
            },
          ),
          if (selectedKategori != null &&
              varietiesByCategory[selectedKategori!] != null &&
              varietiesByCategory[selectedKategori!]!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const BumdesInputLabel("Varietas *", required: true),
            DropdownButtonFormField<String>(
              initialValue: selectedVarietas,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grass),
              ),
              items: varietiesByCategory[selectedKategori]!
                  .map<DropdownMenuItem<String>>((v) {
                    return DropdownMenuItem<String>(value: v, child: Text(v));
                  })
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedVarietas = value;

                  // Update price based on variety
                  final price = getPriceForSelection();
                  if (price != null) {
                    _hargaController.text = CurrencyFormatter.rupiah.format(
                      price.toInt(),
                    );
                  }
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    final price = getPriceForSelection();
    return BumdesSectionCard(
      title: "Harga & Stok",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BumdesPriceField(
            controller: _hargaController,
            labelText: 'Harga per Kg *',
            prefixIcon: Icons.price_change,
            enabled: false,
            readOnly: true,
          ),
          if (selectedKategori != null && price != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                "ℹ️ HPP $selectedKategori${selectedVarietas != null ? ' ($selectedVarietas)' : ''}: Rp ${price.toInt()}/kg",
                style: const TextStyle(color: AppColors.textDark, fontSize: 12),
              ),
            ),
          const SizedBox(height: 14),
          BumdesNumberField(
            controller: _jumlahController,
            labelText: 'Jumlah Stok (kg) *',
            prefixIcon: Icons.numbers,
            readOnly: true,
            hintText: 'Auto-calculated from contributions',
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return BumdesSectionCard(
      title: "Gambar Produk",
      child: BumdesImagePicker(
        selectedImages: selectedImages,
        existingImages: existingImages,
        isEnabled: true,
        onImagesChanged: (images) {
          setState(() {
            selectedImages = images;
          });
        },
        onImagesToDelete: (ids) {
          setState(() {
            imagesToDelete = ids;
          });
        },
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return BumdesSectionCard(
      title: "Lainnya",
      child: BumdesMultilineField(
        controller: _infoTambahanController,
        labelText: 'Info Tambahan',
        maxLines: 3,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext ctx, ProductState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state is ProductLoading ? null : () => _submitUpdate(ctx),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: state is ProductLoading
            ? const AppSmallLoadingIndicator(color: AppColors.white, size: 20.0)
            : const Text(
                "SIMPAN PERUBAHAN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _addContributor() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PetaniContributorDialog(
        petaniList: petaniList
            .map((p) => {'id': p.id, 'name': p.name})
            .toList(),
      ),
    );

    if (result != null) {
      setState(() {
        petaniContributors.add(result);
        _updateTotalQuantity();
      });
    }
  }

  Future<void> _editContributor(int index, Map<String, dynamic> contrib) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PetaniContributorDialog(
        initialData: contrib,
        petaniList: petaniList
            .map((p) => {'id': p.id, 'name': p.name})
            .toList(),
      ),
    );

    if (result != null) {
      setState(() {
        petaniContributors[index] = result;
        _updateTotalQuantity();
      });
    }
  }

  void _updateTotalQuantity() {
    final total = petaniContributors.fold<double>(
      0,
      (sum, contrib) => sum + (contrib['contributed_kg'] as double),
    );
    _jumlahController.text = total.toStringAsFixed(2);
  }

  Future<void> _submitUpdate(BuildContext ctx) async {
    // Validation
    if (_namaProdukController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama produk harus diisi')));
      return;
    }

    if (selectedKategori == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori harus dipilih')));
      return;
    }

    if (petaniContributors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal satu kontributor petani')),
      );
      return;
    }

    // Get price from HPP
    final price = getPriceForSelection();
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harga tidak ditemukan')));
      return;
    }

    // Get harvest date from contributors
    final harvestDate = petaniContributors.isNotEmpty
        ? (petaniContributors[0]['harvest_date'] as String)
        : DateTime.now().toIso8601String().split('T')[0];

    try {
      // Dispatch update product event to bloc
      final event = ProductUpdateRequested(
        productId: widget.product['id'],
        name: _namaProdukController.text,
        categoryId: selectedKategoriId!,
        variety: selectedVarietas ?? 'Standard',
        harvestDate: harvestDate,
        storageDays: int.tryParse(_masaSimpanController.text) ?? 0,
        pricePerKg: price,
        stockKg: double.parse(_jumlahController.text),
        description: _infoTambahanController.text.isEmpty
            ? null
            : _infoTambahanController.text,
        petaniContributors: petaniContributors,
        newImages: selectedImages.isNotEmpty ? selectedImages : null,
        imageIdsToDelete: imagesToDelete.isNotEmpty ? imagesToDelete : null,
      );

      ctx.read<ProductBloc>().add(event);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }
}
