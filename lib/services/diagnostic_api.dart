import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';

class DiagnosticApi {
  final ApiClient _api = ApiClient(baseUrl: AppConfig.baseUrl);
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getHistory({int limit = 10}) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant. Connecte-toi d'abord.");
    }

    return _api.get(
      '/api/diagnostics?limit=$limit',
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}