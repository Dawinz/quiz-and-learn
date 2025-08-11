import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _userData;
  bool _isLoading = false;
  String? _error;

  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _apiService.isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() async {
    if (_apiService.isAuthenticated) {
      await _loadUserData();
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
          spins: {'dailyUsed': 0, 'dailyLimit': 10, 'lastSpinDate': null},
        );
      } else {
        _error = response['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // void _initializeAuth() {
  //   _firebaseService.authStateChanges.listen((User? user) async {
  //     _currentUser = user;
  //     if (user != null) {
  //       await _loadUserData(user.uid);
  //     } else {
  //       _userData = null;
  //     }
  //     notifyListeners();
  //   });
  // }

  // Future<void> _loadUserData(String userId) async {
  //   try {
  //     // First check if user exists in Wallet Hub
  //     final exists = await _firebaseService.userExistsInWalletHub(userId);
  //     if (exists) {
  //       // Fetch existing user data from Wallet Hub
  //       final userData = await _firebaseService.fetchUserFromWalletHub(userId);
  //       if (userData != null) {
  //         _userData = userData;
  //         notifyListeners();
  //       }
  //     } else {
  //       // Create new user profile
  //       final currentUser = _currentUser;
  //       if (currentUser != null) {
  //         await _firebaseService.createUserProfile(
  //           userId,
  //           currentUser.displayName ?? 'User',
  //           currentUser.email ?? '',
  //           currentUser.phoneNumber,
  //         );
  //       }
  //     }

  //     // Listen to user data changes
  //     _firebaseService.getUserDataStream(userId).listen((UserModel? userData) {
  //       _userData = userData;
  //       notifyListeners();
  //     });
  //   } catch (e) {
  //     _error = e.toString();
  //     notifyListeners();
  //   }
  // }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.login(email: email, password: password);
      
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

      final response = await _apiService.getProfile(); // For now, just reload profile
      if (response['success']) {
        await _loadUserData();
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
    // Temporarily simplified for iOS compatibility
    return error.toString();
  }
}
