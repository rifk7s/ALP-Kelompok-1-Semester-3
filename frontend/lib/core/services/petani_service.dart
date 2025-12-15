import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

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
  final http.Client client;

  PetaniService({http.Client? client}) : client = client ?? http.Client();

  Future<List<PetaniData>> fetchAllPetani({required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/petani-data');
    final headers = ApiConfig.headers(token: token);

    final resp = await client
        .get(uri, headers: headers)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout - server tidak merespons');
          },
        );

    if (resp.statusCode == 200) {
      final jsonBody = json.decode(resp.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        final List<dynamic> dataList = jsonBody['data'] as List<dynamic>;
        return dataList
            .map((item) => PetaniData.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else if (resp.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (resp.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal memuat data petani: ${resp.statusCode}');
  }

  Future<PetaniData> createPetani({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/petani-data');
    final headers = ApiConfig.headers(token: token);

    final resp = await client
        .post(uri, headers: headers, body: json.encode(data))
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout - server tidak merespons');
          },
        );

    if (resp.statusCode == 201) {
      final jsonBody = json.decode(resp.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        return PetaniData.fromJson(jsonBody['data'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } else if (resp.statusCode == 422) {
      final errors = json.decode(resp.body);
      final errorMsg = errors['errors'] != null
          ? (errors['errors'] as Map).values.first[0]
          : errors['message'] ?? 'Validation error';
      throw Exception(errorMsg);
    } else if (resp.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (resp.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal menambah petani: ${resp.statusCode}');
  }

  Future<PetaniData> updatePetani({
    required int id,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/petani-data/$id');
    final headers = ApiConfig.headers(token: token);

    final resp = await client
        .put(uri, headers: headers, body: json.encode(data))
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout - server tidak merespons');
          },
        );

    if (resp.statusCode == 200) {
      final jsonBody = json.decode(resp.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        return PetaniData.fromJson(jsonBody['data'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } else if (resp.statusCode == 422) {
      final errors = json.decode(resp.body);
      final errorMsg = errors['errors'] != null
          ? (errors['errors'] as Map).values.first[0]
          : errors['message'] ?? 'Validation error';
      throw Exception(errorMsg);
    } else if (resp.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (resp.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal memperbarui petani: ${resp.statusCode}');
  }

  Future<bool> deletePetani({required int id, required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/petani-data/$id');
    final headers = ApiConfig.headers(token: token);

    final resp = await client
        .delete(uri, headers: headers)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout - server tidak merespons');
          },
        );

    if (resp.statusCode == 200) {
      return true;
    } else if (resp.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (resp.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal menghapus petani: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> fetchPetaniDetail({
    required int petaniId,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/petani-data/$petaniId');
    final headers = ApiConfig.headers(token: token);

    final resp = await client
        .get(uri, headers: headers)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout - server tidak merespons');
          },
        );

    if (resp.statusCode == 200) {
      final jsonBody = json.decode(resp.body);
      if (jsonBody is Map && jsonBody.containsKey('data')) {
        return jsonBody['data'] as Map<String, dynamic>;
      }
      throw Exception('Invalid response format');
    } else if (resp.statusCode == 401) {
      throw Exception('Token expired atau tidak valid');
    } else if (resp.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses (hanya BumDes)');
    }

    throw Exception('Gagal memuat detail petani: ${resp.statusCode}');
  }
}
