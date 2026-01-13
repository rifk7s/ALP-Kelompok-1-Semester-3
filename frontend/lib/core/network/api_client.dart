import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final String? hint;
  final bool isConnectionError;
  final int? statusCode;

  ApiException(
    this.message, {
    this.hint,
    this.isConnectionError = false,
    this.statusCode,
  });

  @override
  String toString() => hint != null ? '$message\n$hint' : message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late http.Client _client;

  ApiClient._internal() {
    _client = http.Client();
  }

  // Timeout durations
  Duration get _timeout => Duration(seconds: ApiConfig.connectionTimeout);

  // GET request
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
          .timeout(timeout ?? _timeout),
    );
  }

  // POST request (JSON body)
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
            body: body is String ? body : json.encode(body),
          )
          .timeout(timeout ?? _timeout),
    );
  }

  // PUT request (JSON body)
  Future<http.Response> put(
    String endpoint, {
    String? token,
    Object? body,
    Duration? timeout,
  }) async {
    return _executeWithFallback(
      () => _client
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: ApiConfig.headers(token: token),
            body: body is String ? body : json.encode(body),
          )
          .timeout(timeout ?? _timeout),
    );
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    String? token,
    Duration? timeout,
  }) async {
    return _executeWithFallback(
      () => _client
          .delete(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(timeout ?? _timeout),
    );
  }

  // PATCH request (JSON body)
  Future<http.Response> patch(
    String endpoint, {
    String? token,
    Object? body,
    Duration? timeout,
  }) async {
    return _executeWithFallback(
      () => _client
          .patch(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: ApiConfig.headers(token: token),
            body: body is String ? body : json.encode(body),
          )
          .timeout(timeout ?? _timeout),
    );
  }

  // Multipart POST request (for file uploads)
  Future<http.Response> multipartPost(
    String endpoint, {
    String? token,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Duration? timeout,
  }) async {
    return _executeWithFallback(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send().timeout(
        timeout ?? Duration(seconds: ApiConfig.receiveTimeout),
      );
      return http.Response.fromStream(streamedResponse);
    });
  }

  // Execute request with IP fallback on connection failure
  Future<http.Response> _executeWithFallback(
    Future<http.Response> Function() request,
  ) async {
    // Reset to primary IP before starting - ensures we always try best IP first
    ApiConfig.resetToPrimaryIP();

    // Try all available IPs
    for (var i = 0; i < ApiConfig.availableIPs.length; i++) {
      try {
        return await request();
      } on TimeoutException {
        if (!ApiConfig.tryNextIP()) {
          throw _createConnectionError('Connection timed out');
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

// Global instance for easy access
final apiClient = ApiClient();
