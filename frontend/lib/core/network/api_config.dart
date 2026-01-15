import 'dart:io';

class ApiConfig {
  // Android Emulator: 10.0.2.2 (special emulator IP yang selalu mengarah ke host machine)
  // Ini TIDAK berubah meskipun IP komputer berubah - 10.0.2.2 adalah hardcoded alias
  // iOS Simulator & Physical device: IP komputer (localhost tidak work di iOS simulator!)
  // NOTE: Run backend with: php artisan serve --host=0.0.0.0 --port=8000

  // URLs for API endpoints
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000/api';

  // iOS IPs - Priority order: tries home first, then cafe as fallback
  static const String _homeIP = '192.168.18.182'; // Home IP (primary)
  static const String _cafeIP = '192.168.1.18'; // Cafe IP (fallback)

  // List of IPs to try in priority order (home first!)
  static const List<String> _ipPriority = [_homeIP, _cafeIP];

  // Connection timeout - very short for fast failure detection
  static const int connectionTimeout = 2;
  static const int receiveTimeout = 10;

  // Current active IP (defaults to first in priority list)
  static String _currentIP = _ipPriority.first;

  static String _iosDeviceUrl = 'http://$_currentIP:8000/api';

  // Base URLs for images/storage
  static const String _androidEmulatorBase = 'http://10.0.2.2:8000';
  static String _iosDeviceBase = 'http://$_currentIP:8000';

  // Get all available IPs to try
  static List<String> get availableIPs => _ipPriority;

  // Get current active IP
  static String get currentIP => _currentIP;

  // Set active iOS IP (call this when home IP fails to auto-switch to cafe)
  static void setIOSDeviceIP(String ip) {
    _currentIP = ip;
    _iosDeviceUrl = 'http://$ip:8000/api';
    _iosDeviceBase = 'http://$ip:8000';
  }

  // Try next IP in priority list (useful for automatic fallback)
  static bool tryNextIP() {
    final currentIndex = _ipPriority.indexOf(_currentIP);
    if (currentIndex < _ipPriority.length - 1) {
      setIOSDeviceIP(_ipPriority[currentIndex + 1]);
      return true;
    }
    return false; // No more IPs to try
  }

  // Reset to primary IP (call before starting a new request cycle)
  static void resetToPrimaryIP() {
    if (_currentIP != _ipPriority.first) {
      setIOSDeviceIP(_ipPriority.first);
    }
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
