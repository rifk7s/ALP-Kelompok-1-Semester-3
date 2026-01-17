import 'package:frontend/features/auth/service/auth_service.dart';
import 'package:frontend/core/storage/storage_service.dart';

/// Repository layer for authentication operations.
/// Wraps AuthService and StorageService for a unified auth API.
class AuthRepository {
  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
    required String address,
    String role = 'pembeli',
    String? email,
  }) async {
    return AuthService.register(
      name: name,
      phone: phone,
      password: password,
      address: address,
      role: role,
      email: email,
    );
  }

  /// Login with phone and password
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    return AuthService.login(phone: phone, password: password);
  }

  /// Logout current user
  Future<AuthResult> logout() async {
    return AuthService.logout();
  }

  /// Get current user from API
  Future<AuthResult> getMe() async {
    return AuthService.getMe();
  }

  /// Check if user is logged in (from local storage)
  Future<bool> isLoggedIn() async {
    return StorageService.isLoggedIn();
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getStoredUser() async {
    return StorageService.getUser();
  }

  /// Clear all stored data
  Future<void> clearStorage() async {
    await StorageService.clearAll();
  }
}
