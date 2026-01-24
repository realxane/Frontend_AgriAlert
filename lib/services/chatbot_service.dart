import 'dart:convert';
import 'package:agri_alert/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotService {
  Future<String?> askQuestion(String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/ia/chatbot'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'question': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['reponse'];
      }
      return "Désolé, je n'ai pas pu répondre pour le moment.";
    } catch (e) {
      return "Erreur de connexion.";
    }
  }
}
