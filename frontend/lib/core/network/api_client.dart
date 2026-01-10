import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final String? hint;
  final bool isConnectionError;

  ApiException(this.message, {this.hint, this.isConnectionError = false});

  @override
  String toString() => hint != null ? '$message\n$hint' : message;
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(
    String endpoint, {
    String? token,
    Duration? timeout,
  }) async {
    return _executeWithFallback(
      () => _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(timeout ?? Duration(seconds: ApiConfig.connectionTimeout)),
    );
  }

  Future<http.Response> post(
    String endpoint, {
    String? token,
    Object? body,
    Duration? timeout,
  }) async {
    return _executeWithFallback(
      () => _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: ApiConfig.headers(token: token),
            body: body,
          )
          .timeout(timeout ?? Duration(seconds: ApiConfig.connectionTimeout)),
    );
  }

  Future<http.Response> _executeWithFallback(
    Future<http.Response> Function() request,
  ) async {
    // Try all available IPs
    for (var i = 0; i < ApiConfig.availableIPs.length; i++) {
      try {
        return await request();
      } on TimeoutException {
        if (!ApiConfig.tryNextIP()) {
          throw _createConnectionError('Connection failed');
        }
      } on SocketException {
        if (!ApiConfig.tryNextIP()) {
          throw _createConnectionError('Connection failed');
        }
      }
    }
    throw _createConnectionError('Connection failed');
  }

  ApiException _createConnectionError(String baseMessage) {
    final allIPs = ApiConfig.availableIPs.join(', ');

    return ApiException(
      baseMessage,
      hint:
          'Tried IPs: $allIPs\n'
          'Make sure backend is running on one of these IPs.',
      isConnectionError: true,
    );
  }

  void close() {
    _client.close();
  }
}
