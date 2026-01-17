import 'dart:convert';
import 'package:frontend/core/network/api_client.dart';

class PetaniData {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final bool isActive;

  PetaniData({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    required this.isActive,
  });

  factory PetaniData.fromJson(Map<String, dynamic> json) {
    return PetaniData(
      id: json['id'] as int,
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

class PetaniService {
  Future<List<PetaniData>> fetchAllPetani({required String token}) async {
    final response = await apiClient.get('/petani-data', token: token);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        final List<dynamic> dataList = jsonBody['data'] as List<dynamic>;
        return dataList
            .map((item) => PetaniData.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (response.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal memuat data petani: ${response.statusCode}');
  }

  Future<PetaniData> createPetani({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final response = await apiClient.post(
      '/petani-data',
      token: token,
      body: data,
    );

    if (response.statusCode == 201) {
      final jsonBody = json.decode(response.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        return PetaniData.fromJson(jsonBody['data'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } else if (response.statusCode == 422) {
      final errors = json.decode(response.body);
      final errorMsg = errors['errors'] != null
          ? (errors['errors'] as Map).values.first[0]
          : errors['message'] ?? 'Validation error';
      throw Exception(errorMsg);
    } else if (response.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (response.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal menambah petani: ${response.statusCode}');
  }

  Future<PetaniData> updatePetani({
    required int id,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final response = await apiClient.put(
      '/petani-data/$id',
      token: token,
      body: data,
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        return PetaniData.fromJson(jsonBody['data'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } else if (response.statusCode == 422) {
      final errors = json.decode(response.body);
      final errorMsg = errors['errors'] != null
          ? (errors['errors'] as Map).values.first[0]
          : errors['message'] ?? 'Validation error';
      throw Exception(errorMsg);
    } else if (response.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (response.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal memperbarui petani: ${response.statusCode}');
  }

  Future<bool> deletePetani({required int id, required String token}) async {
    final response = await apiClient.delete('/petani-data/$id', token: token);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (response.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal menghapus petani: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> fetchPetaniDetail({
    required int petaniId,
    required String token,
  }) async {
    final response = await apiClient.get(
      '/petani-data/$petaniId',
      token: token,
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        return jsonBody['data'] as Map<String, dynamic>;
      }
      throw Exception('Invalid response format');
    } else if (response.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (response.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal memuat detail petani: ${response.statusCode}');
  }
}
