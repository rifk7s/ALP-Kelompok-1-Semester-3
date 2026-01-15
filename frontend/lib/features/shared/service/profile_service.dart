import 'dart:convert';
import 'package:frontend/core/network/api_client.dart';

class Profile {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? email;

  Profile({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      email: json['email'],
    );
  }
}

class ProfileService {
  Future<Profile> fetchProfile({String? token}) async {
    final response = await apiClient.get('/profile/me', token: token);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return Profile.fromJson(jsonBody);
    }
    throw Exception('Gagal memuat profil: ${response.statusCode}');
  }

  Future<Profile> updateProfile({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final response = await apiClient.patch(
      '/profile/update',
      token: token,
      body: data,
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      final dataJson = jsonBody['data'] ?? jsonBody;
      return Profile.fromJson(dataJson as Map<String, dynamic>);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token invalid atau expired');
    } else if (response.statusCode == 422) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      final errors =
          jsonBody['errors'] ?? jsonBody['message'] ?? 'Validation failed';
      throw Exception('Error validasi: $errors');
    }
    throw Exception(
      'Gagal memperbarui profil: Status ${response.statusCode}',
    );
  }
}
