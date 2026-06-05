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
  
  // Variable estática para mantener el token en memoria
  static String? _token;

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
    
    final Map<String, String> headers = {
      'ngrok-skip-browser-warning': 'true',   // ← CABECERA CLAVE PARA NGROK
    };

    if (isMultipart) {
      if (token != null) headers['Authorization'] = 'Bearer $token';
      return headers;
    }

    headers['Content-Type'] = 'application/json; charset=utf-8';
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: await _headers(),   // ← USA LAS CABECERAS CORRECTAS
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
  // MÉTODOS HTTP
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
      final headers = await _headers(isMultipart: true);
      // Debug: imprimir el token
      final tokenEnviado = headers['Authorization'];
      print('Token enviado al escanear: $tokenEnviado');
      request.headers.addAll(headers);
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

  // NUEVO MÉTODO PARA ACTUALIZAR AVATAR CON PATCH
  Future<Map<String, dynamic>?> patchMultipart(String url, Map<String, String> fields, File? image) async {
    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(await _headers(isMultipart: true));
      request.fields.addAll(fields);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', image.path));
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