import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BumdesInfo {
  final String id;
  final String name;
  final String? phone;

  BumdesInfo({required this.id, required this.name, this.phone});

  factory BumdesInfo.fromJson(Map<String, dynamic> json) {
    return BumdesInfo(
      id: json['id'].toString(),
      name: json['name'] ?? 'BUMDes',
      phone: json['phone'],
    );
  }
}

class BumdesService {
  static BumdesInfo? _cachedBumdes;

  static Future<BumdesInfo?> getBumdesInfo() async {
    if (_cachedBumdes != null) return _cachedBumdes;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bumdes'),
        headers: ApiConfig.headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedBumdes = BumdesInfo.fromJson(data);
        return _cachedBumdes;
      }
    } catch (e) {
      print('BumdesService error: $e');
    }
    return null;
  }

  static void clearCache() {
    _cachedBumdes = null;
  }
}
