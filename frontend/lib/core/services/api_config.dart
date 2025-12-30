import 'dart:io';

class ApiConfig {
  // Android Emulator: 10.0.2.2 (special emulator IP yang selalu mengarah ke host machine)
  // Ini TIDAK berubah meskipun IP komputer berubah - 10.0.2.2 adalah hardcoded alias
  // iOS Simulator & Physical device: IP komputer (localhost tidak work di iOS simulator!)
  // NOTE: Run backend with: php artisan serve --host=0.0.0.0 --port=8000

  // URLs for API endpoints
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000/api';
  static String _iosDeviceUrl = 'http://192.168.18.182:8000/api'; // IP komputer untuk semua iOS

  // Base URLs for images/storage
  static const String _androidEmulatorBase = 'http://10.0.2.2:8000';
  static String _iosDeviceBase = 'http://192.168.18.182:8000'; // IP komputer untuk semua iOS

  // Setter untuk update iOS IP secara dinamis (dipanggil dari settings atau config)
  static void setIOSDeviceIP(String ip) {
    _iosDeviceUrl = 'http://$ip:8000/api';
    _iosDeviceBase = 'http://$ip:8000';
  }

  static String get baseUrl {
    if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    } else {
      // iOS (simulator & physical) gunakan IP komputer
      // Localhost (127.0.0.1) TIDAK work di iOS simulator!
      return _iosDeviceUrl;
    }
  }

  static String get baseServerUrl {
    if (Platform.isAndroid) {
      return _androidEmulatorBase;
    } else {
      // iOS (simulator & physical) gunakan IP komputer
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

    // Cek apakah path sudah mengandung 'storage/'
    if (relativePath.startsWith('storage/')) {
      // Sudah ada 'storage/' di path, jangan tambah lagi
      final path = relativePath.startsWith('/')
          ? relativePath.substring(1) // Buang leading slash
          : relativePath;
      return '$baseServerUrl/$path';
    }

    // Path belum ada 'storage/', tambahkan
    final path = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    return '$baseServerUrl/storage/$path';
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
