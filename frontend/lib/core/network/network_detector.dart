import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:frontend/core/network/api_config.dart';
import 'package:flutter/foundation.dart';

/// Service for detecting the correct backend IP address
/// Used at app startup to automatically find which network (home/cafe) is available
class NetworkDetector {
  // Short timeout for fast detection - fail quickly if backend not reachable
  static const Duration _detectionTimeout = Duration(seconds: 2);

  // Health check endpoint (assumes Laravel has /api/health or we use /api/ping)
  static const String _healthEndpoint = '/auth/login'; // Use existing endpoint

  /// Detects which backend IP is reachable and sets it as active
  ///
  /// Returns:
  /// - `true` if a reachable IP was found and set
  /// - `false` if no IP is reachable (backend not running)
  static Future<bool> detectAndSetActiveIP() async {
    if (ApiConfig.baseUrl.startsWith('10.0.2.2')) {
      // Android emulator uses 10.0.2.2 which always works
      debugPrint('🔵 Android emulator detected - using 10.0.2.2');
      return true;
    }

    debugPrint('🔍 Starting network detection...');
    debugPrint('📋 Available IPs: ${ApiConfig.availableIPs}');

    // Try each IP in priority order
    for (final ip in ApiConfig.availableIPs) {
      final isReachable = await _checkIP(ip);
      if (isReachable) {
        ApiConfig.setIOSDeviceIP(ip);
        debugPrint('✅ Backend reachable at: $ip');
        return true;
      }
    }

    debugPrint('❌ No reachable backend found - backend may not be running');
    return false;
  }

  /// Check if a specific IP is reachable
  static Future<bool> _checkIP(String ip) async {
    try {
      final url = 'http://$ip:8000/api$_healthEndpoint';
      debugPrint('  🔎 Testing $ip...');

      // Use POST to /auth/login with empty body - will return validation error
      // but if we get a response, the backend is running
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          )
          .timeout(_detectionTimeout);

      // Any response means backend is running
      // We expect validation error (422) or auth error (401), both mean backend is up
      if (response.statusCode >= 400 && response.statusCode < 500) {
        debugPrint('  ✅ $ip: Backend is running (status: ${response.statusCode})');
        return true;
      }

      debugPrint('  ⚠️ $ip: Unexpected status ${response.statusCode}');
      return false;
    } on TimeoutException {
      debugPrint('  ❌ $ip: Timeout');
      return false;
    } catch (e) {
      debugPrint('  ❌ $ip: $e');
      return false;
    }
  }

  /// Quick check if current backend is reachable
  /// Returns true if reachable, false otherwise
  static Future<bool> isBackendReachable() async {
    try {
      final url = '${ApiConfig.baseUrl}/auth/login';
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));

      // 4xx responses mean backend is running
      return response.statusCode >= 400 && response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
}
