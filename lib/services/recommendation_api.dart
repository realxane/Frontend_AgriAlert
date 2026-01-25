import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';

class RecommendationApi {
  final ApiClient _api = ApiClient(baseUrl: AppConfig.baseUrl);
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getMyChamps() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant. Connecte-toi.");
    }

    return _api.get(
      '/api/champs',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> getChamp(String champId) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant. Connecte-toi.");
    }

    return _api.get(
      '/api/champs/$champId',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> recommendationsByCulture({
    required String champId,
    required String cultureId,
  }) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant. Connecte-toi.");
    }

    return _api.get(
      '/api/recommendations/cultures/$cultureId?champ_id=$champId',
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
