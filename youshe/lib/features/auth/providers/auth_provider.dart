import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserRole? _userRole;
  bool _isLoading = true;
  String? _error;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  User? get user => _user;
  UserRole? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  void _onAuthStateChanged(User? user) {
    _user = user;
    if (user != null) {
      _loadUserRole(user.uid);
    } else {
      _userRole = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      _userRole = await _authService.getUserRole(uid);
    } catch (e) {
      _userRole = UserRole.customer;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, UserRole role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(email, password, name, role);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInAnonymously();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _userRole = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
