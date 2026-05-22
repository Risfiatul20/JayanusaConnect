import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_client.dart' show handleDioError;

class ProfileService {
  final Dio _dio = ApiClient().dio;

  /// GET /api/profile — data profil user
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }

  /// GET /api/registrations?type=training — riwayat pelatihan
  Future<Map<String, dynamic>> getTrainingHistory() async {
    try {
      final response = await _dio.get('/registrations', queryParameters: {
        'type': 'training',
      });
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }

  /// GET /api/aspirations — jumlah aspirasi user
  Future<int> getAspirationCount() async {
    try {
      final response = await _dio.get('/aspirations');
      final data = response.data['data'];
      return data['total'] ?? (data['data'] as List? ?? []).length;
    } catch (_) {
      return 0;
    }
  }
}
