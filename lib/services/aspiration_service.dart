import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_client.dart' show handleDioError;

class AspirationService {
  final Dio _dio = ApiClient().dio;

  /// GET /api/aspirations — list aspirasi milik user (mahasiswa) atau semua (admin)
  Future<Map<String, dynamic>> getAspirations({String? status, String? category}) async {
    try {
      final response = await _dio.get('/aspirations', queryParameters: {
        if (status != null) 'status': status,
        if (category != null) 'category': category,
      });
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }

  /// POST /api/aspirations — kirim aspirasi baru
  Future<Map<String, dynamic>> createAspiration({
    required String title,
    required String content,
    String? category,
  }) async {
    try {
      final response = await _dio.post('/aspirations', data: {
        'title': title,
        'content': content,
        if (category != null && category.isNotEmpty) 'category': category,
      });
      return response.data;
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      return {'success': false, 'message': handleDioError(e), 'errors': errors};
    }
  }

  /// GET /api/aspirations/{id} — detail aspirasi
  Future<Map<String, dynamic>> getAspiration(int id) async {
    try {
      final response = await _dio.get('/aspirations/$id');
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }

  /// DELETE /api/aspirations/{id} — hapus aspirasi
  Future<Map<String, dynamic>> deleteAspiration(int id) async {
    try {
      final response = await _dio.delete('/aspirations/$id');
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }
}
