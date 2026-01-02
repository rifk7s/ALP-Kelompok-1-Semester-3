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
    try {
      return await request();
    } on TimeoutException {
      throw _createConnectionError('Connection timeout');
    } on SocketException catch (e) {
      throw _createConnectionError('Cannot connect: ${e.message}');
    }
  }

  ApiException _createConnectionError(String baseMessage) {
    final currentIP = ApiConfig.currentIP;
    final allIPs = ApiConfig.availableIPs.join(', ');
    
    return ApiException(
      baseMessage,
      hint: 'Current IP: $currentIP\n'
          'Available IPs: $allIPs\n'
          'Make sure backend is running and your IP matches.',
      isConnectionError: true,
    );
  }

  void close() {
    _client.close();
  }
}
