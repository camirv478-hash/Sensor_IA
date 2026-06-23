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
  // AUTENTICACIÓN Y REGISTRO
  // ============================================

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    _token ??= await _storage.read(key: 'jwt_token');
    return _token;
  }

  Future<Map<String, String>> _headers({bool isMultipart = false, bool isForm = false}) async {
    final token = await getToken();
    
    final Map<String, String> headers = {
      'ngrok-skip-browser-warning': 'true',   // Mantenemos compatibilidad con Ngrok si es necesario
    };

    if (isMultipart) {
      if (token != null) headers['Authorization'] = 'Bearer $token';
      return headers;
    }

    if (isForm) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    } else {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }

    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // Método para Iniciar Sesión (Login)
  Future<dynamic> login(String username, String password) async {
    try {
      print('--- 🔐 INTENTANDO INICIAR SESIÓN ---');
      print('URL Destino Login: ${ApiConstants.login}');
      
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: await _headers(),
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode == 200) {
        await setToken(body['access']);
        return true;
      }
      return body ?? {'detail': 'Error de autenticación'};
    } catch (e) {
      print('Login error: $e');
      return {'detail': 'Error de red. Revisa tu conexión.'};
    }
  }

  // Método para crear/registrar una cuenta nueva
  Future<dynamic> registerUser(Map<String, dynamic> userData) async {
    try {
      print('--- 📝 INTENTANDO CREAR CUENTA ---');
      final String urlRegistro = ApiConstants.register; 
      
      print('URL Destino Registro: $urlRegistro');
      print('Datos enviados: ${jsonEncode(userData)}');

      final response = await http.post(
        Uri.parse(urlRegistro),
        headers: await _headers(),
        body: jsonEncode(userData),
      );

      print('Registro response status: ${response.statusCode}');
      print('Registro response body: ${response.body}');

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; // Usuario creado con éxito
      }
      
      return body ?? {'detail': 'Error al crear la cuenta.'};
    } catch (e) {
      print('Error crítico en registro: $e');
      return {'detail': 'Error de red. Revisa tu conexión.'};
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
  // MÉTODOS HTTP GENERALES
  // ============================================

  Future<dynamic> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('🚨 Error en GET ($url): $e');
      return null;
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {'success': response.statusCode >= 200 && response.statusCode < 300};
    } catch (e) {
      print('🚨 Error en POST ($url): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> postForm(String url, Map<String, String> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(isForm: true),
        body: body,
      );
      
      print('Form response status: ${response.statusCode}');
      print('Form response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) return jsonDecode(response.body);
        return {'success': true};
      }
      return null;
    } catch (e) {
      print('🚨 Error en postForm: $e');
      return null;
    }
  }

  Future<dynamic> patchJson(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      if (response.body.isNotEmpty) return jsonDecode(response.body);
      return {};
    } catch (e) {
      print('🚨 Error en PATCH ($url): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> postMultipart(String url, Map<String, String> fields, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      final headers = await _headers(isMultipart: true);
      
      print('Token enviado al escanear: ${headers['Authorization']}');
      
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('imagen', image.path));
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } catch (e) {
      print('🚨 Error en postMultipart: $e');
      return null;
    }
  }

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
      print('🚨 Error en patchMultipart: $e');
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
      print('🚨 Error en getList ($url): $e');
      return null;
    }
  }
}