import 'dart:io';

class ApiConfig {
  // Android Emulator: 10.0.2.2
  // iOS/Physical device: IP komputer
  // NOTE: Run backend with: php artisan serve --host=0.0.0.0 --port=8001
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000/api';
  static const String _iosDeviceUrl = 'http://192.168.18.227:8000/api';

  static String get baseUrl {
    if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    } else {
      return _iosDeviceUrl;
    }
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
