import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator
  static const String baseUrl = 'http://127.0.0.1:8000/api'; 
  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 10));
    return _handle(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 10));
    return _handle(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 10));
    return _handle(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 10));
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final isJson = response.headers['content-type']?.contains('application/json') ?? false;
    final decoded = isJson && response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'Request failed (${response.statusCode})';
    throw ApiException(response.statusCode, message);
  }
}