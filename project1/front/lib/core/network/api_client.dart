import 'dart:convert';
import 'package:http/http.dart' as http;

import '../error/api_exception.dart';

class ApiClient {
  // static const String baseUrl = 'http://10.33.130.21:8080/api';
  static const String baseUrl = 'http://192.168.200.161:8080/api';
  // static const String baseUrl = 'http://172.28.6.110:8080/api';

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String?>? queryParams}) async {
    final uri = _buildUri(path, queryParams);

    final response = await _client.get(uri, headers: _headers());
    
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path, null);
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    
    return _handleResponse(response);
  }

  Future<void> delete(String path) async {
    final uri = _buildUri(path, null);
    final response = await _client.delete(uri, headers: _headers());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'DELETE $path 실패',
      );
    }
  }

  Uri _buildUri(String path, Map<String, String?>? queryParams) {
    final base = Uri.parse('$baseUrl$path');

    if (queryParams == null || queryParams.isEmpty) return base;

    final filtered = Map.fromEntries(
      queryParams.entries.where((e) => e.value != null && e.value!.isNotEmpty),
    ).cast<String, String>();

    return base.replace(queryParameters: filtered);
  }

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
  };

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _parseErrorMessage(response.body),
    );
  }

  String _parseErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}
