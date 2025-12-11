import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/petani_service.dart';
import 'package:frontend/core/services/storage_service.dart';

class TambahPetaniScreen extends StatefulWidget {
  const TambahPetaniScreen({super.key});

  @override
  State<TambahPetaniScreen> createState() => _TambahPetaniScreenState();
}

class _TambahPetaniScreenState extends State<TambahPetaniScreen> {
  final _petaniService = PetaniService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final namaController = TextEditingController();
    final hpController = TextEditingController();
    final alamatController = TextEditingController();

    Future<void> handleSave() async {
      final nama = namaController.text.trim();
      final hp = hpController.text.trim();
      final alamat = alamatController.text.trim();

      if (nama.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Gagal"),
            content: const Text("Nama petani wajib diisi."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Get token from storage
        final token = await StorageService.getToken();
        if (token == null) {
          throw Exception('Token tidak ditemukan. Silakan login kembali.');
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
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Berhasil"),
            content: Text("Petani \"${newPetani.name}\" berhasil ditambahkan."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
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

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
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
            customInput("Nama Lengkap *", namaController),
            const SizedBox(height: 18),

            customInput(
              "Nomor HP *",
              hpController,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 18),

            customInput("Alamat (Opsional)", alamatController, maxLines: 3),
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
