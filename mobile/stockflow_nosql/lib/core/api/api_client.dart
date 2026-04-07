import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final String _baseUrl;

  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  Future<dynamic> get(String path, {String? token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    String? token,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token, hasBody: true),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, String> _headers(String? token, {bool hasBody = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (hasBody) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 204) {
      return null;
    }

    if (response.statusCode >= 400) {
      var message = 'Request failed with status ${response.statusCode}.';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = (body['detail'] ?? body['title'] ?? message) as String;
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }
}
