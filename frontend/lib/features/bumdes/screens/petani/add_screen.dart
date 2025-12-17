import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/petani_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/core/utils/ui_helpers.dart';

class TambahPetaniScreen extends StatefulWidget {
  const TambahPetaniScreen({super.key});

  @override
  State<TambahPetaniScreen> createState() => _TambahPetaniScreenState();
}

class _TambahPetaniScreenState extends State<TambahPetaniScreen> {
  final _petaniService = PetaniService();
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _hpController = TextEditingController();
  final _alamatController = TextEditingController();

  // Shake keys
  final _namaShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> handleSave() async {
      final nama = _namaController.text.trim();
      final hp = _hpController.text.trim();
      final alamat = _alamatController.text.trim();

      if (nama.isEmpty) {
        _namaShakeKey.currentState?.shake();
        SnackBarHelper.showError(context, 'Nama petani wajib diisi');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Get token from storage
        final token = await StorageService.getToken();
        if (token == null) {
          throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
        }

        // Prepare data
        final data = {
          'name': nama,
          if (hp.isNotEmpty) 'phone': hp,
          if (alamat.isNotEmpty) 'address': alamat,
        };

        // Call API
        final newPetani = await _petaniService.createPetani(
          data: data,
          token: token,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Berhasil"),
            content: Text("Petani \"${newPetani.name}\" berhasil ditambahkan."),
            actions: [
              TextButton(
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.pop(context); // Close dialog
                  if (!context.mounted) return;
                  Navigator.pop(
                    context,
                    true,
                  ); // Return to manage screen with success flag
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Kesalahan"),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Tambah Data Petani",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            ShakeWidget(
              key: _namaShakeKey,
              child: customInput("Nama Lengkap *", _namaController),
            ),
            const SizedBox(height: 18),

            customInput(
              "Nomor HP *",
              _hpController,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 18),

            customInput("Alamat (Opsional)", _alamatController, maxLines: 3),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
