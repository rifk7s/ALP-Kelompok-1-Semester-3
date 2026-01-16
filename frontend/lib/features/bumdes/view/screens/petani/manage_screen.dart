import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/bumdes/bloc/petani/petani_bloc.dart';
import 'package:frontend/features/bumdes/bloc/petani/petani_event.dart';
import 'package:frontend/features/bumdes/bloc/petani/petani_state.dart';
import 'package:frontend/features/bumdes/repository/petani_repository.dart';

class KelolaPetaniScreen extends StatelessWidget {
  const KelolaPetaniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PetaniBloc(
        petaniRepository: sl<PetaniRepository>(),
      )..add(const PetaniLoadRequested()),
      child: const _KelolaPetaniContent(),
    );
  }
}

class _KelolaPetaniContent extends StatelessWidget {
  const _KelolaPetaniContent();

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
            onPressed: () => _navigateToAddScreen(context),
          ),
        ],
      ),
      body: BlocBuilder<PetaniBloc, PetaniState>(
        builder: (context, state) {
          return RetryableContent(
            isLoading: state.isLoading,
            hasError: state.hasError,
            errorMessage: state.errorMessage,
            onRetry: () =>
                context.read<PetaniBloc>().add(const PetaniLoadRequested()),
            child: state.petaniList.isEmpty
                ? EmptyStateWidget(
                    message: 'Belum ada data petani',
                    subMessage: 'Tambahkan data baru dengan tombol + di atas',
                    icon: Icons.people_outline,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<PetaniBloc>().add(
                            const PetaniLoadRequested(showSpinner: false),
                          );
                    },
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
                        itemCount: state.petaniList.length,
                        itemBuilder: (context, index) {
                          final petani = state.petaniList[index];
                          return _PetaniCard(
                            name: petani.name,
                            phone: petani.phone ?? '-',
                            onTap: () =>
                                _navigateToDetailScreen(context, petani.id),
                          );
                        },
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddScreen(BuildContext context) async {
    final result = await context.push(RoutePaths.petaniAdd);

    // If result is true, reload the list
    if (result == true && context.mounted) {
      context.read<PetaniBloc>().add(const PetaniLoadRequested(showSpinner: false));
    }
  }

  Future<void> _navigateToDetailScreen(BuildContext context, int petaniId) async {
    final result = await context.push(
      RoutePaths.petaniDetail.replaceAll(':id', '$petaniId'),
    );

    // If result is true (deleted/updated), reload the list
    if (result == true && context.mounted) {
      context.read<PetaniBloc>().add(const PetaniLoadRequested(showSpinner: false));
    }
  }
}

class _PetaniCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onTap;

  const _PetaniCard({
    required this.name,
    required this.phone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  color: AppColors.warningAccent.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    fontSize: 26,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
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
                phone,
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
  }
}
