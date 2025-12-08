class ApiConfig {
  // Untuk Android Emulator gunakan 10.0.2.2
  // Untuk iOS Simulator gunakan 127.0.0.1
  // Untuk physical device gunakan IP komputer (contoh: 192.168.x.x)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

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
