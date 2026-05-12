import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;

  // ============================================
  // AUTENTICACIÓN
  // ============================================

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    _token ??= await _storage.read(key: 'jwt_token');
    return _token;
  }

  Future<Map<String, String>> _headers({bool isMultipart = false}) async {
    final token = await getToken();
    if (isMultipart) {
      return {
        if (token != null) 'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> get isLoggedIn async {
    final token = await getToken();
    return token != null;
  }

  // ============================================
  // GET, POST, PUT, DELETE genéricos
  // ============================================

  Future<Map<String, dynamic>?> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> postMultipart(String url, Map<String, String> fields, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await _headers(isMultipart: true));
      request.fields.addAll(fields);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('imagen', image.path));
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getList(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}