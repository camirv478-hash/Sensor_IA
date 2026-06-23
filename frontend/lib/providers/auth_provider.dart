import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _stats;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  
  Map<String, dynamic>? get stats => _stats;

  // Getter seguro para exponer el perfil mapeado correctamente
  Map<String, dynamic>? get profile => _profile;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.login(username, password);
      print('Login result: $result');
      bool success = false;

      if (result == true) {
        success = true;
        _isLoggedIn = true;
        await loadProfile(silent: true);
        await loadStats(silent: true);
      } else if (result is Map<String, dynamic>) {
        if (result['detail'] != null) {
          _errorMessage = result['detail'].toString();
        } else if (result['non_field_errors'] != null) {
          _errorMessage = result['non_field_errors'][0].toString();
        } else if (result['username'] != null) {
          _errorMessage = result['username'][0].toString();
        } else if (result['password'] != null) {
          _errorMessage = result['password'][0].toString();
        } else {
          _errorMessage = 'Credenciales incorrectas';
        }
      } else {
        _errorMessage = 'Credenciales incorrectas';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Error de conexión con el servidor';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile({bool silent = false}) async {
    try {
      final data = await _api.get(ApiConstants.profile);
      if (data is Map<String, dynamic>) {
        _profile = data;
      }
    } catch (e) {
      print('Error cargando perfil: $e');
      _profile = null;
    } finally {
      if (!silent) notifyListeners();
    }
  }

  Future<void> loadStats({bool silent = false}) async {
    try {
      final data = await _api.get(ApiConstants.stats);
      if (data is Map<String, dynamic>) {
        _stats = data;
      }
    } catch (e) {
      print('Error cargando estadísticas: $e');
      _stats = null;
    } finally {
      if (!silent) notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      print('Error durante logout en servidor: $e');
    } finally {
      _isLoggedIn = false;
      _profile = null;
      _stats = null;
      notifyListeners();
    }
  }

  Future<bool> checkLogin() async {
    try {
      _isLoggedIn = await _api.isLoggedIn;
      if (_isLoggedIn) {
        await Future.wait([
          loadProfile(silent: true),
          loadStats(silent: true),
        ]);
      }
    } catch (e) {
      print('Error al verificar sesión: $e');
      _isLoggedIn = false;
    } finally {
      notifyListeners();
    }
    return _isLoggedIn;
  }

  Future<String?> getToken() async {
    return await _api.getToken();
  }
  
  bool get esAdmin {
    final rol = _profile?['rol'] ?? 'user';
    return rol == 'admin' || rol == 'Administrador';
  }
}