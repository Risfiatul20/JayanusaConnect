import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/kampus_auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final KampusAuthService _kampusAuthService = KampusAuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Cek status login saat app dibuka
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _user = await _authService.getCurrentUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Login via API Kampus JAYANUSA menggunakan NOBP
  /// Ini adalah login utama untuk mahasiswa
  Future<bool> loginWithNobp(String nobp, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _kampusAuthService.loginWithNobp(
      nobp: nobp,
      password: password,
    );

    if (result['success'] == true) {
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Login via backend Laravel kita (untuk admin BEM / super admin)
  Future<bool> loginAdmin(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);
    if (result['success'] == true) {
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Register akun baru via backend Laravel (khusus admin BEM)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? nim,
    String? phone,
    String? angkatan,
    String? prodi,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      nim: nim,
      phone: phone,
      angkatan: angkatan,
      prodi: prodi,
    );

    if (result['success'] == true) {
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = result['message'];
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return result;
  }

  /// Register Alumni — buat akun user + data alumni sekaligus
  Future<Map<String, dynamic>> registerAlumni({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String angkatan,
    String? nim,
    String? phone,
    String? prodi,
    String? profession,
    String? company,
    String? position,
    String? linkedin,
    String? bio,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.registerAlumni(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      angkatan: angkatan,
      nim: nim,
      phone: phone,
      prodi: prodi,
      profession: profession,
      company: company,
      position: position,
      linkedin: linkedin,
      bio: bio,
    );

    if (result['success'] == true) {
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = result['message'];
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return result;
  }

  /// Logout — handle kedua jenis login
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    if (_user?.isKampusLogin == true) {
      await _kampusAuthService.logout();
    } else {
      await _authService.logout();
    }

    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Update user data lokal
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
