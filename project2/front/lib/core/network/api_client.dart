import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../error/api_exception.dart';
import '../storage/token_storage.dart';

class ApiClient {
  // static const String baseUrl = 'http://10.252.60.21:8080/api';
  // static const String baseUrl = 'http://172.28.6.110:8080/api';
  // static const String baseUrl = 'http://10.181.32.21:8080/api';
  // static const String baseUrl = 'http://192.168.0.193:8080/api';
  static const String baseUrl = 'http://43.203.212.14:8080/api';
  // static const String baseUrl = 'http://10.36.230.21:8080/api';

  final http.Client _client;
  final TokenStorage? _tokenStorage;

  ApiClient({http.Client? client, TokenStorage? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage;

  Future<dynamic> get(String path, {Map<String, String?>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    return _executeWithRetry(() => _client.get(uri, headers: _headers()));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path, null);
    final encoded = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      () => _client.post(uri, headers: _headers(), body: encoded),
    );
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path, null);
    final encoded = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      () => _client.patch(uri, headers: _headers(), body: encoded),
    );
  }

  Future<dynamic> patchMultipart(
    String path, {
    required Map<String, dynamic> jsonFields,
    String jsonPartName = 'request',
    String? fileField,
    List<int>? fileBytes,
    String? fileName,
    String? mimeType,
  }) async {
    final uri = _buildUri(path, null);

    Future<http.Response> doRequest() async {
      final request = http.MultipartRequest('PATCH', uri);
      request.headers.addAll(_authHeader());
      request.files.add(http.MultipartFile.fromString(
        jsonPartName,
        jsonEncode(jsonFields),
        contentType: MediaType('application', 'json'),
      ));
      if (fileBytes != null && fileField != null) {
        final mediaType =
            mimeType != null ? MediaType.parse(mimeType) : MediaType('image', 'jpeg');
        request.files.add(http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName ?? 'image',
          contentType: mediaType,
        ));
      }
      final streamed = await _client.send(request);
      return http.Response.fromStream(streamed);
    }

    return _executeWithRetry(doRequest);
  }

  Future<dynamic> postMultipart(
    String path, {
    required Map<String, dynamic> jsonFields,
    String jsonPartName = 'request',
    String? fileField,
    List<int>? fileBytes,
    String? fileName,
    String? mimeType,
  }) async {
    final uri = _buildUri(path, null);

    Future<http.Response> doRequest() async {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_authHeader());
      request.files.add(http.MultipartFile.fromString(
        jsonPartName,
        jsonEncode(jsonFields),
        contentType: MediaType('application', 'json'),
      ));
      if (fileBytes != null && fileField != null) {
        final mediaType =
            mimeType != null ? MediaType.parse(mimeType) : MediaType('image', 'jpeg');
        request.files.add(http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName ?? 'image',
          contentType: mediaType,
        ));
      }
      final streamed = await _client.send(request);
      return http.Response.fromStream(streamed);
    }

    return _executeWithRetry(doRequest);
  }

  Future<void> deleteWithBody(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path, null);
    final encoded = body != null ? jsonEncode(body) : null;

    Future<http.Response> doRequest() async {
      final req = http.Request('DELETE', uri);
      req.headers.addAll(_headers());
      if (encoded != null) req.body = encoded;
      return http.Response.fromStream(await _client.send(req));
    }

    var response = await doRequest();

    if (response.statusCode == 401 && _tokenStorage?.refreshToken != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) response = await doRequest();
    }

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }
  }

  Future<void> delete(String path) async {
    final uri = _buildUri(path, null);

    var response = await _client.delete(uri, headers: _headers());

    if (response.statusCode == 401 && _tokenStorage?.refreshToken != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await _client.delete(uri, headers: _headers());
      }
    }

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }
  }

  // ── 내부 헬퍼 ──────────────────────────────────────────────────────

  Future<dynamic> _executeWithRetry(
    Future<http.Response> Function() fn,
  ) async {
    var response = await fn();

    if (response.statusCode == 401 && _tokenStorage?.refreshToken != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) response = await fn();
    }

    return _handleResponse(response);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = _tokenStorage!.refreshToken!;
      final uri = _buildUri('/auth/refresh', null);
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await _tokenStorage!.save(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        return true;
      }

      await _tokenStorage!.clear();
      return false;
    } catch (_) {
      await _tokenStorage?.clear();
      return false;
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
        'Content-Type': 'application/json; charset=utf-8',
        ..._authHeader(),
      };

  Map<String, String> _authHeader() {
    final token = _tokenStorage?.accessToken;
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

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
