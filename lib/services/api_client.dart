import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final resp = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body == null ? null : jsonEncode(body),
    );

    final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // Laravel renvoie souvent {message: "..."} en erreur
      final msg = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : resp.body;
      throw Exception(msg);
    }

    return (decoded as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);

    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    );

    final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final msg = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : resp.body;
      throw Exception(msg);
    }

    return (decoded as Map<String, dynamic>);
  }
}
