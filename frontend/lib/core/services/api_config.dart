import 'dart:io';

class ApiConfig {
  // Android Emulator: 10.0.2.2
  // iOS/Physical device: IP komputer
  // NOTE: Run backend with: php artisan serve --host=0.0.0.0 --port=8000
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000/api';
  static const String _iosDeviceUrl = 'http://10.1.50.240:8000/api';

  static const String _androidEmulatorBase = 'http://10.0.2.2:8000';
  static const String _iosDeviceBase = 'http://10.1.50.240:8000';

  static String get baseUrl {
    final url = Platform.isAndroid ? _androidEmulatorUrl : _iosDeviceUrl;

    return url;
  }

  static String get baseServerUrl {
    if (Platform.isAndroid) {
      return _androidEmulatorBase;
    } else {
      return _iosDeviceBase;
    }
  }

  // Convert relative storage path to full URL
  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    // If already a full URL, return as is
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }
    // Remove leading slash if present
    final path = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    return '$baseServerUrl/$path';
  }

  static Map<String, String> headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
