import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';

class WeatherApi {
  final ApiClient _api = ApiClient(baseUrl: AppConfig.baseUrl);
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> today({required String champId}) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant. Connecte-toi d'abord.");
    }

    return _api.get(
      '/api/weather/today?champ_id=$champId',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> forecast({required String champId, int days = 7}) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant. Connecte-toi d'abord.");
    }

    return _api.get(
      '/api/weather/forecast?champ_id=$champId&days=$days',
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}