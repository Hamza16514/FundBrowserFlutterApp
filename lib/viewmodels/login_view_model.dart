import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class LoginViewModel extends ChangeNotifier {
  final SecureStorageService _storageService;

  LoginViewModel({SecureStorageService? storageService})
      : _storageService = storageService ?? SecureStorageService() {
    _loadStoredEmail();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// The email of the currently logged-in user (null if not logged in).
  String? _userEmail;
  String? get userEmail => _userEmail;

  /// Returns up to 2 uppercase initials derived from the user's email.
  /// e.g. "john.doe@gmail.com" → "JD", "alice@gmail.com" → "AL"
  String get avatarInitials {
    if (_userEmail == null || _userEmail!.isEmpty) return '??';
    final local = _userEmail!.split('@').first; // take local part before @
    final parts = local.split(RegExp(r'[._\-]')); // split on . _ -
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (local.length >= 2) {
      return local.substring(0, 2).toUpperCase();
    }
    return local[0].toUpperCase();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Loads the persisted email (used on cold start when user is already logged in).
  Future<void> _loadStoredEmail() async {
    _userEmail = await _storageService.getEmail();
    notifyListeners();
  }

  // Simulate network validation and login
  Future<bool> login(String email, String password) async {
    _setError(null);
    _setLoading(true);

    try {
      // Simulate API latency
      await Future.delayed(const Duration(milliseconds: 1000));

      if (email.trim().isEmpty || password.isEmpty) {
        _setError('Email and password cannot be empty');
        _setLoading(false);
        return false;
      }

      // Save session token and email for future sessions
      final dummyToken = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      await _storageService.saveToken(dummyToken);
      await _storageService.saveEmail(email.trim());

      _userEmail = email.trim();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Checks if user is already logged in
  Future<bool> checkAutoLogin() async {
    return await _storageService.hasToken();
  }

  // Logout utility — clears token, email and notifies listeners
  Future<void> logout() async {
    await _storageService.deleteToken();
    await _storageService.deleteEmail();
    _userEmail = null;
    notifyListeners();
  }
}
