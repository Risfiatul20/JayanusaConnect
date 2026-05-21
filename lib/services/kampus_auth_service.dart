import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Service untuk autentikasi via API kampus JAYANUSA
/// Endpoint: https://api.novinaldi.my.id/api/login-voting
class KampusAuthService {
  late final Dio _dio;

  KampusAuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.kampusApiUrl,
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 15000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Login via sistem kampus menggunakan NOBP dan password
  /// Request: {"username": "NOBP", "password": "password"}
  /// Response sukses: {"success": true, "data": {"nobp": "...", "nama": "..."}}
  /// Response gagal: {"success": false, "message": "..."}
  Future<Map<String, dynamic>> loginWithNobp({
    required String nobp,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.kampusLoginEndpoint,
        data: {
          'username': nobp.trim(),
          'password': password,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        final user = UserModel.fromKampusJson(data['data']);

        // Simpan data user ke local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        await prefs.setString(AppConstants.nobpKey, nobp.trim());

        // Tandai sebagai kampus login (tidak ada token Sanctum)
        await prefs.setString(AppConstants.tokenKey, 'kampus_${nobp.trim()}');

        return {
          'success': true,
          'user': user,
          'message': data['message'] ?? 'Login berhasil',
        };
      }

      return {
        'success': false,
        'message': data['message'] ??
            'Username atau Password salah, atau anda tidak terdaftar di semester ini.',
      };
    } on DioException catch (e) {
      // Handle error spesifik dari API kampus
      if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke server kampus. Periksa koneksi internet.',
        };
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message': 'Koneksi ke server kampus timeout. Coba lagi.',
        };
      }

      // Cek response body untuk pesan error dari server
      final responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        return {
          'success': false,
          'message': responseData['message'],
        };
      }

      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga.',
      };
    }
  }

  /// Logout — hapus data lokal (tidak ada endpoint logout di API kampus)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.nobpKey);
  }
}
