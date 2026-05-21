import 'dart:convert';
import 'dart:developer' as developer;
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
          // PENTING: API kampus menerima form-data, bukan JSON
          // Content-Type di-set per-request via FormData
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
      developer.log(
        'Attempting login: URL=${AppConstants.kampusApiUrl}${AppConstants.kampusLoginEndpoint}, NOBP=$nobp',
        name: 'KampusAuth',
      );

      // PENTING: API kampus menerima multipart/form-data, bukan JSON
      final formData = FormData.fromMap({
        'username': nobp.trim(),
        'password': password,
      });

      final response = await _dio.post(
        AppConstants.kampusLoginEndpoint,
        data: formData,
      );

      final data = response.data;
      developer.log('Response status: ${response.statusCode}', name: 'KampusAuth');
      developer.log('Response data: $data', name: 'KampusAuth');

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
      // Log detail error untuk debugging
      developer.log('DioException type: ${e.type}', name: 'KampusAuth');
      developer.log('DioException message: ${e.message}', name: 'KampusAuth');
      developer.log('Response status: ${e.response?.statusCode}', name: 'KampusAuth');
      developer.log('Response data: ${e.response?.data}', name: 'KampusAuth');
      developer.log('Request URL: ${e.requestOptions.uri}', name: 'KampusAuth');

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
      developer.log('Unknown error: $e', name: 'KampusAuth');
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
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
