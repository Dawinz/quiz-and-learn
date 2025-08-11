import "package:flutter/material.dart";
import "../services/api_service.dart";
import "../models/user_model.dart";

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _userData;
  bool _isLoading = true;
  String? _error;

  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userData != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() async {
    try {
      if (!const bool.fromEnvironment("dart.vm.product")) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final hasValidToken = await _apiService.validateToken();

      if (hasValidToken) {
        await _loadUserData();
      } else {
        _isLoading = false;
        _userData = null;
        notifyListeners();
      }
    } catch (e) {
      print("Auth initialization error: $e");
      _error = e.toString();
      _isLoading = false;
      _userData = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final response = await _apiService.getProfile();
      if (response["success"]) {
        _userData = UserModel.fromMap(response["data"]["user"]);
        _error = null;
      } else {
        await _apiService.logout();
        _userData = null;
        _error = response["error"] ?? "Failed to load user data";
      }
    } catch (e) {
      print("Load user data error: $e");
      await _apiService.logout();
      _userData = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print("Attempting login for email: $email");
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      print("Login response: $response");

      if (response["success"]) {
        await _loadUserData();
        return null;
      } else {
        _error = response["error"] ?? "Login failed";
        _isLoading = false;
        notifyListeners();
        return _error;
      }
    } catch (e) {
      print("Login error: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return _error;
    }
  }

  Future<String?> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print("Attempting registration for email: $email");
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        referralCode: referralCode,
      );

      print("Registration response: $response");

      if (response["success"]) {
        await _loadUserData();
        return null;
      } else {
        _error = response["error"] ?? "Registration failed";
        _isLoading = false;
        notifyListeners();
        return _error;
      }
    } catch (e) {
      print("Registration error: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return _error;
    }
  }

  Future<void> signOut() async {
    try {
      await _apiService.logout();
      _userData = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _loadUserData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
