import 'package:flutter/material.dart';
import 'add_screen.dart';
import 'detail_screen.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/petani_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/core/utils/ui_helpers.dart';

class KelolaPetaniScreen extends StatefulWidget {
  const KelolaPetaniScreen({super.key});

  @override
  State<KelolaPetaniScreen> createState() => _KelolaPetaniScreenState();
}

class _KelolaPetaniScreenState extends State<KelolaPetaniScreen> {
  final _petaniService = PetaniService();
  List<PetaniData> _petaniList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPetaniData();
  }

  Future<void> _loadPetaniData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      final data = await _petaniService.fetchAllPetani(token: token);

      if (!mounted) return;

      setState(() {
        _petaniList = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahPetaniScreen()),
    );

    // If result is true, reload the list
    if (result == true) {
      _loadPetaniData();
    }
  }

  Future<void> _navigateToDetailScreen(PetaniData petani) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PetaniDetailScreen(petaniId: petani.id),
      ),
    );

    // If result is true (deleted), reload the list
    if (result == true) {
      _loadPetaniData();
    }
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
            color: AppColors.textLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddScreen,
          ),
        ],
      ),

      body: RetryableContent(
        isLoading: _isLoading,
        hasError: _errorMessage != null,
        errorMessage: _errorMessage,
        onRetry: _loadPetaniData,
        child: _petaniList.isEmpty
            ? EmptyStateWidget(
                message: 'Belum ada data petani',
                subMessage: 'Tambahkan data baru dengan tombol + di atas',
                icon: Icons.people_outline,
              )
            : RefreshIndicator(
                onRefresh: _loadPetaniData,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _petaniList.length,
                    itemBuilder: (context, index) {
                      final petani = _petaniList[index];
                      final nama = petani.name;
                      final hp = petani.phone ?? '-';

                      return GestureDetector(
                        onTap: () => _navigateToDetailScreen(petani),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.warningAccent.withValues(
                                      alpha: 0.85,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    nama.isNotEmpty
                                        ? nama[0].toUpperCase()
                                        : 'P',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  nama,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  hp,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
