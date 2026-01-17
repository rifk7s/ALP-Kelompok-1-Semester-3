import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/features/bumdes/bloc/petani/petani_event.dart';
import 'package:frontend/features/bumdes/bloc/petani/petani_state.dart';
import 'package:frontend/features/bumdes/repository/petani_repository.dart';

/// BLoC for petani (farmer) management
/// Handles CRUD operations for petani data
class PetaniBloc extends Bloc<PetaniEvent, PetaniState> {
  final PetaniRepository _petaniRepository;

  PetaniBloc({required PetaniRepository petaniRepository})
      : _petaniRepository = petaniRepository,
        super(const PetaniState()) {
    on<PetaniLoadRequested>(_onLoadRequested);
    on<PetaniCreateRequested>(_onCreateRequested);
    on<PetaniUpdateRequested>(_onUpdateRequested);
    on<PetaniDeleteRequested>(_onDeleteRequested);
    on<PetaniReset>(_onReset);
  }

  Future<String?> _getToken() async {
    return StorageService.getToken();
  }

  Future<void> _onLoadRequested(
    PetaniLoadRequested event,
    Emitter<PetaniState> emit,
  ) async {
    if (event.showSpinner) {
      emit(state.copyWith(
        isLoading: true,
        hasError: false,
        errorMessage: null,
        successMessage: null,
      ));
    }

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      // Run API call and minimum delay in parallel for UX
      final petaniFuture = _petaniRepository.fetchAllPetani(token: token);
      final delayFuture = event.showSpinner
          ? Future.delayed(LoadingDelayConstants.standardList)
          : Future.value();

      final data = await petaniFuture;
      await delayFuture;

      emit(state.copyWith(
        petaniList: data,
        isLoading: false,
        hasError: false,
        errorMessage: null,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading petani: $e');
      }
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCreateRequested(
    PetaniCreateRequested event,
    Emitter<PetaniState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, successMessage: null));

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      final data = <String, dynamic>{
        'name': event.name,
        if (event.phone != null && event.phone!.isNotEmpty)
          'phone': event.phone,
        if (event.address != null && event.address!.isNotEmpty)
          'address': event.address,
      };

      final newPetani = await _petaniRepository.createPetani(
        data: data,
        token: token,
      );

      emit(state.copyWith(
        isMutating: false,
        successMessage: 'Petani "${newPetani.name}" berhasil ditambahkan',
      ));

      // Reload list
      add(const PetaniLoadRequested(showSpinner: false));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating petani: $e');
      }
      emit(state.copyWith(
        isMutating: false,
        hasError: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateRequested(
    PetaniUpdateRequested event,
    Emitter<PetaniState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, successMessage: null));

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      final data = <String, dynamic>{
        'name': event.name,
        if (event.phone != null) 'phone': event.phone,
        if (event.address != null) 'address': event.address,
      };

      final updatedPetani = await _petaniRepository.updatePetani(
        id: event.id,
        data: data,
        token: token,
      );

      emit(state.copyWith(
        isMutating: false,
        successMessage: 'Petani "${updatedPetani.name}" berhasil diperbarui',
      ));

      // Reload list
      add(const PetaniLoadRequested(showSpinner: false));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating petani: $e');
      }
      emit(state.copyWith(
        isMutating: false,
        hasError: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteRequested(
    PetaniDeleteRequested event,
    Emitter<PetaniState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, successMessage: null));

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      await _petaniRepository.deletePetani(id: event.id, token: token);

      emit(state.copyWith(
        isMutating: false,
        successMessage: 'Petani berhasil dihapus',
      ));

      // Reload list
      add(const PetaniLoadRequested(showSpinner: false));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting petani: $e');
      }
      emit(state.copyWith(
        isMutating: false,
        hasError: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onReset(
    PetaniReset event,
    Emitter<PetaniState> emit,
  ) {
    emit(const PetaniState());
  }
}
