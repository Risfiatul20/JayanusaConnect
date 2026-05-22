import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_client.dart' show handleDioError;

class TrainingService {
  final Dio _dio = ApiClient().dio;

  /// GET /api/trainings — list pelatihan dengan filter
  Future<Map<String, dynamic>> getTrainings({String? category, String? search}) async {
    try {
      final response = await _dio.get('/trainings', queryParameters: {
        if (category != null && category != 'Semua') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        'status': 'open', // default hanya tampilkan yang open
      });
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }

  /// GET /api/trainings/{id} — detail pelatihan
  Future<Map<String, dynamic>> getTraining(int id) async {
    try {
      final response = await _dio.get('/trainings/$id');
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': handleDioError(e)};
    }
  }

  /// POST /api/trainings/{id}/register — daftar pelatihan
  Future<Map<String, dynamic>> registerTraining(int id) async {
    try {
      final response = await _dio.post('/trainings/$id/register');
      return response.data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return {'success': false, 'message': msg ?? handleDioError(e)};
    }
  }
}
