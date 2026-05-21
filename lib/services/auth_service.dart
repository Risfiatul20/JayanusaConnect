import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data['success'] == true) {
        final token = data['data']['token'];
        final user = UserModel.fromJson(data['data']['user']);

        // Simpan token dan user ke local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

        return {'success': true, 'user': user, 'token': token};
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }

  // Register
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
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (nim != null) 'nim': nim,
        if (phone != null) 'phone': phone,
        if (angkatan != null) 'angkatan': angkatan,
        if (prodi != null) 'prodi': prodi,
      });

      final data = response.data;
      if (data['success'] == true) {
        final token = data['data']['token'];
        final user = UserModel.fromJson(data['data']['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

        return {'success': true, 'user': user, 'token': token};
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      return {
        'success': false,
        'message': handleDioError(e),
        'errors': errors,
      };
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Tetap logout meski request gagal
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    return true;
  }

  // Get current user dari local storage
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  // Cek apakah sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Refresh user data dari API
  Future<UserModel?> refreshUser() async {
    try {
      final response = await _dio.get('/auth/me');
      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        return user;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
