import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/features/shared/service/chat_service.dart';

// Fast timeout for quick UX feedback - user shouldn't wait more than 5 seconds
const Duration _authTimeout = Duration(seconds: 5);

class AuthResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? errors;
  final bool isUnauthorized; // Token expired/invalid

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.errors,
    this.isUnauthorized = false,
  });
}

class AuthService {
  static Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
    required String address,
    String role = 'pembeli',
    String? email,
  }) async {
    try {
      final body = {
        'name': name,
        'phone': phone,
        'password': password,
        'address': address,
        'role': role,
      };
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      final response = await apiClient.post(
        '/auth/register',
        body: body,
        timeout: _authTimeout,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Registrasi berhasil!',
          user: data['user'],
        );
      } else if (response.statusCode == 422) {
        return AuthResult(
          success: false,
          message: 'Validasi gagal',
          errors: data['errors'],
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Registrasi gagal',
        );
      }
    } on ApiException catch (e) {
      return AuthResult(
        success: false,
        message: e.isConnectionError
            ? 'Backend tidak terjangkau. Pastikan server berjalan dengan: php artisan serve --host=0.0.0.0 --port=8000'
            : e.message,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  static Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        body: {'phone': phone, 'password': password},
        timeout: _authTimeout,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await StorageService.saveToken(data['access_token']);
        await StorageService.saveUser(data['user']);
        if (data['firebase_custom_token'] != null) {
          await StorageService.saveFirebaseToken(data['firebase_custom_token']);
        }

        return AuthResult(
          success: true,
          message: data['message'] ?? 'Login berhasil!',
          user: data['user'],
        );
      } else if (response.statusCode == 401) {
        return AuthResult(
          success: false,
          message: 'Nomor HP atau kata sandi salah',
        );
      } else if (response.statusCode == 422) {
        return AuthResult(
          success: false,
          message: 'Validasi gagal',
          errors: data['errors'],
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Login gagal',
        );
      }
    } on ApiException catch (e) {
      return AuthResult(
        success: false,
        message: e.isConnectionError
            ? 'Backend tidak terjangkau. Pastikan server berjalan dengan: php artisan serve --host=0.0.0.0 --port=8000'
            : e.message,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  static Future<AuthResult> logout() async {
    try {
      // Sign out from Firebase first
      await ChatService.signOutFromFirebase();

      final token = await StorageService.getToken();
      if (token == null) {
        await StorageService.clearAll();
        return AuthResult(success: true, message: 'Logout berhasil');
      }

      await apiClient.post(
        '/auth/logout',
        token: token,
        timeout: const Duration(seconds: 10),
      );

      await StorageService.clearAll();
      return AuthResult(success: true, message: 'Logout berhasil');
    } catch (e) {
      debugPrint('Logout error: $e');
      await StorageService.clearAll();
      return AuthResult(success: true, message: 'Logout berhasil');
    }
  }

  static Future<AuthResult> getMe() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return AuthResult(
          success: false,
          message: 'Tidak ada token',
          isUnauthorized: true,
        );
      }

      final response = await apiClient.get(
        '/me',
        token: token,
        timeout: _authTimeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await StorageService.saveUser(data);
        return AuthResult(success: true, user: data);
      } else if (response.statusCode == 401) {
        // Token expired atau invalid - clear storage
        await StorageService.clearAll();
        return AuthResult(
          success: false,
          message: 'Sesi telah berakhir, silakan masuk kembali',
          isUnauthorized: true,
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Gagal mendapatkan data user',
        );
      }
    } on ApiException catch (e) {
      return AuthResult(
        success: false,
        message: e.isConnectionError ? 'Koneksi gagal' : e.message,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
