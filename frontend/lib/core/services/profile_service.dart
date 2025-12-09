import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

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
  final http.Client client;

  ProfileService({http.Client? client}) : client = client ?? http.Client();

  Future<Profile> fetchProfile({String? token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/me');
    final headers = ApiConfig.headers(token: token);

    final resp = await client.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      return Profile.fromJson(jsonBody);
    }
    throw Exception('Failed to load profile: \\$resp');
  }

  Future<Profile> updateProfile({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/profile/update');
      final headers = ApiConfig.headers(token: token);

      final resp = await client
          .patch(uri, headers: headers, body: json.encode(data))
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
        final dataJson = jsonBody['data'] ?? jsonBody;
        return Profile.fromJson(dataJson as Map<String, dynamic>);
      } else if (resp.statusCode == 401) {
        throw Exception('Unauthorized: Token invalid atau expired');
      } else if (resp.statusCode == 422) {
        final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
        final errors = jsonBody['errors'] ?? jsonBody['message'] ?? 'Validation failed';
        throw Exception('Validation error: $errors');
      }
      throw Exception('Failed to update profile: Status ${resp.statusCode}, Body: ${resp.body}');
    } catch (e) {
      rethrow;
    }
  }
}