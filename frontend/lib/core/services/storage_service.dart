import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _firebaseTokenKey = 'firebase_token';

  // Secure storage untuk data sensitif (tokens)
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Save token dengan enkripsi
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Get token dari secure storage
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // User data bisa pakai SharedPreferences (non-sensitive)
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  // Firebase token juga sensitif, pakai secure storage
  static Future<void> saveFirebaseToken(String token) async {
    await _secureStorage.write(key: _firebaseTokenKey, value: token);
  }

  static Future<String?> getFirebaseToken() async {
    return await _secureStorage.read(key: _firebaseTokenKey);
  }

  // Clear semua data saat logout
  static Future<void> clearAll() async {
    // Clear secure storage
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _firebaseTokenKey);
    
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
