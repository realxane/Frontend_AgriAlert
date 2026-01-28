import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ProfileService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String nom,
    required String telephone,
    required String email,
    File? image,
  }) async {
    final uri = Uri.parse('$baseUrl/api/profile/update');

    // Création de la requête MultiPart
    var request = http.MultipartRequest('POST', uri);

    // Ajout des headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Ajout des champs texte
    request.fields['nom'] = nom;
    request.fields['telephone'] = telephone;
    request.fields['email'] = email;

    // Ajout de l'image si elle est présente
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', image.path));
    }

    // Envoi de la requête
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? "Erreur lors de la modification");
    }
  }

  Future<Map<String, dynamic>> updateChamp({
    required String token,
    required String nom,
    required String regionId,
    required double latitude,
    required double longitude,
    required double aire,
    // Note: Ton backend actuel ne gère qu'une seule culture via culture_id
    // Si tu veux gérer plusieurs cultures, il faudra adapter le contrôleur Laravel
    int? cultureId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/profile/update-champ'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nom': nom,
        'region_id': regionId,
        'latitude': latitude,
        'longitude': longitude,
        'aire': aire,
        if (cultureId != null) 'culture_id': cultureId,
      }),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return decoded;
    } else {
      throw Exception(
        decoded['message'] ?? "Erreur lors de la mise à jour du champ",
      );
    }
  }
}
