import 'package:frontend/features/bumdes/service/petani_service.dart';

/// Repository layer for Petani operations.
/// Wraps PetaniService for unified Petani API.
class PetaniRepository {
  final PetaniService _petaniService;

  PetaniRepository({PetaniService? petaniService})
      : _petaniService = petaniService ?? PetaniService();

  /// Fetch all petani data
  Future<List<PetaniData>> fetchAllPetani({required String token}) async {
    return _petaniService.fetchAllPetani(token: token);
  }

  /// Create new petani
  Future<PetaniData> createPetani({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    return _petaniService.createPetani(data: data, token: token);
  }

  /// Update existing petani
  Future<PetaniData> updatePetani({
    required int id,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    return _petaniService.updatePetani(id: id, data: data, token: token);
  }

  /// Delete petani
  Future<bool> deletePetani({required int id, required String token}) async {
    return _petaniService.deletePetani(id: id, token: token);
  }

  /// Fetch petani detail
  Future<Map<String, dynamic>> fetchPetaniDetail({
    required int petaniId,
    required String token,
  }) async {
    return _petaniService.fetchPetaniDetail(petaniId: petaniId, token: token);
  }
}
