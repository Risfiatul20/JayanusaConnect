import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
          'Accept': 'application/json',
        },
      ),
    );

    // Bypass SSL certificate validation untuk API kampus
    // API kampus menggunakan self-signed / untrusted certificate
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  /// Login via sistem kampus menggunakan NOBP dan password
  /// API menerima multipart/form-data (bukan JSON)
  /// Response sukses: {"success": true, "data": {"nobp": "...", "nama": "..."}}
  Future<Map<String, dynamic>> loginWithNobp({
    required String nobp,
    required String password,
  }) async {
    try {
      developer.log(
        'Login attempt → NOBP: $nobp | URL: ${AppConstants.kampusApiUrl}${AppConstants.kampusLoginEndpoint}',
        name: 'KampusAuth',
      );
      // ignore: avoid_print
      print('[KampusAuth] Login attempt → NOBP: $nobp');

      // API kampus wajib pakai multipart/form-data
      final formData = FormData.fromMap({
        'username': nobp.trim(),
        'password': password,
      });

      final response = await _dio.post(
        AppConstants.kampusLoginEndpoint,
        data: formData,
      );

      final data = response.data;
      developer.log('Response [${response.statusCode}]: $data', name: 'KampusAuth');
      // ignore: avoid_print
      print('[KampusAuth] Response [${response.statusCode}]: $data');

      if (data['success'] == true) {
        final user = UserModel.fromKampusJson(data['data']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        await prefs.setString(AppConstants.nobpKey, nobp.trim());
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
      developer.log('DioException → type: ${e.type} | msg: ${e.message}', name: 'KampusAuth');
      developer.log('Response → status: ${e.response?.statusCode} | data: ${e.response?.data}', name: 'KampusAuth');
      developer.log('URL: ${e.requestOptions.uri}', name: 'KampusAuth');

      switch (e.type) {
        case DioExceptionType.connectionError:
          return {
            'success': false,
            'message': 'Tidak dapat terhubung ke server kampus. Periksa koneksi internet.',
          };
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return {
            'success': false,
            'message': 'Koneksi ke server kampus timeout. Coba lagi.',
          };
        case DioExceptionType.badResponse:
          final msg = e.response?.data?['message'];
          return {
            'success': false,
            'message': msg ?? 'Server mengembalikan error: ${e.response?.statusCode}',
          };
        default:
          final msg = e.response?.data?['message'];
          if (msg != null) {
            return {'success': false, 'message': msg};
          }
          return {
            'success': false,
            'message': 'Terjadi kesalahan koneksi. Coba lagi.',
          };
      }
    } catch (e, stack) {
      developer.log('Unknown error: $e\n$stack', name: 'KampusAuth');
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga.',
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.nobpKey);
  }
}
