import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _userData;
  bool _isLoading = true; // Start with loading true
  String? _error;

  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _apiService.isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() async {
    try {
      // Wait a bit for the API service to initialize
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if we have a valid token
      final hasValidToken = await _apiService.validateToken();

      if (hasValidToken) {
        await _loadUserData();
      } else {
        // No valid authentication, show login screen
        _isLoading = false;
        _userData = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _userData = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getProfile();
      if (response['success']) {
        final userData = response['data']['user'];
        _userData = UserModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'],
          coins: userData['totalCoins'] ?? 0,
          goals: {},
        );
      } else {
        _error = response['error'];
        // If profile fetch fails, clear authentication
        await _apiService.logout();
      }
    } catch (e) {
      _error = e.toString();
      // If there's an error, clear authentication
      await _apiService.logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await _apiService.login(email: email, password: password);

      if (response['success']) {
        await _loadUserData();
        return true;
      } else {
        _error = response['error'];
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      if (response['success']) {
        await _loadUserData();
        return true;
      } else {
        _error = response['error'];
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<bool> signInWithGoogle() async {  // Temporarily disabled
  //   try {
  //     _isLoading = true;
  //     _error = null;
  //     notifyListeners();

  //     final credential = await _firebaseService.signInWithGoogle();
  //     if (credential?.user != null) {
  //       // Check if user profile exists, if not create one
  //       final userData = await _firebaseService.getUserData(credential!.user!.uid);
  //       if (userData == null) {
  //         await _firebaseService.createUserProfile(
  //           credential.user!.uid,
  //           credential.user!.displayName ?? 'User',
  //           credential.user!.email ?? '',
  //           credential.user!.phoneNumber,
  //         );
  //       }
  //     }
  //     return true;
  //   } catch (e) {
  //     _error = _getErrorMessage(e);
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> signOut() async {
    try {
      await _apiService.logout();
      _userData = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.updateProfile(
        name: data['name'] ?? _userData?.name ?? '',
        email: data['email'] ?? _userData?.email ?? '',
      );

      if (response['success']) {
        // Update local user data
        if (_userData != null) {
          _userData = UserModel(
            id: _userData!.id,
            name: data['name'] ?? _userData!.name,
            email: data['email'] ?? _userData!.email,
            phone: _userData!.phone,
            coins: _userData!.coins,
            goals: _userData!.goals,
          );
        }
        _error = null;
      } else {
        _error = response['error'];
      }
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    // Simplified error handling for API service
    return error.toString();
  }
}
