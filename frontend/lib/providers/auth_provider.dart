import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _stats;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get profile => _profile;
  Map<String, dynamic>? get stats => _stats;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _api.login(username, password);
    if (success) {
      _isLoggedIn = true;
      await loadProfile();
      await loadStats();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> loadProfile() async {
    _profile = await _api.get(ApiConstants.profile);
    notifyListeners();
  }

  Future<void> loadStats() async {
    _stats = await _api.get(ApiConstants.stats);
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    _isLoggedIn = false;
    _profile = null;
    _stats = null;
    notifyListeners();
  }

  Future<bool> checkLogin() async {
    _isLoggedIn = await _api.isLoggedIn;
    if (_isLoggedIn) {
      await loadProfile();
      await loadStats();
    }
    notifyListeners();
    return _isLoggedIn;
  }
}