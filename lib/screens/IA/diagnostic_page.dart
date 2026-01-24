import 'dart:io';
import 'dart:convert';
import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_colors.dart';

class DiagnosticPage extends StatefulWidget {
  final String imagePath;

  const DiagnosticPage({super.key, required this.imagePath});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  final _storage = const FlutterSecureStorage();
  final TextEditingController _chatCtrl = TextEditingController();

  // On utilise une variable locale pour pouvoir changer l'image si on en choisit une nouvelle
  late String _currentImagePath;
  bool _isAnalysing = true;
  String _maladieDetectee = "Analyse en cours...";
  String _conseilIA = "L'expert agronome prépare ses conseils...";
  bool _isSendingChat = false;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _runFullDiagnosis();
  }

  // --- LOGIQUE 1 : DIAGNOSTIC ---
  Future<void> _runFullDiagnosis() async {
    setState(() {
      _isAnalysing = true;
      _maladieDetectee = "Analyse en cours...";
    });

    try {
      final token = await _storage.read(key: 'access_token');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/ia/diagnostic'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', _currentImagePath),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          // Formatage à 2 chiffres après la virgule
          double confidence = double.parse(
            data['resultat']['confidence'].toString(),
          );
          String confidenceFormatted = confidence.toStringAsFixed(2);

          _maladieDetectee =
              "${data['resultat']['maladie_detectee']} $confidenceFormatted%";
          _conseilIA =
              data['resultat']['recommendation_ia'] ?? "Aucun conseil trouvé.";
          _isAnalysing = false;
        });
      } else {
        setState(() {
          _maladieDetectee = "Erreur ${response.statusCode}";
          _isAnalysing = false;
        });
      }
    } catch (e) {
      setState(() {
        _maladieDetectee = "Erreur de connexion";
        _isAnalysing = false;
      });
    }
  }

  // --- LOGIQUE 2 : CHATBOT ---
  Future<void> _askChatbot() async {
    if (_chatCtrl.text.trim().isEmpty) return;
    setState(() => _isSendingChat = true);
    final question = _chatCtrl.text.trim();
    final maladiePure = _maladieDetectee.split(' ').first;

    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/ia/chatbot'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': question,
          'maladie_detectee': maladiePure,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _conseilIA = data['Reponse'];
          _chatCtrl.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur Chatbot: $e")));
    } finally {
      setState(() => _isSendingChat = false);
    }
  }

  // --- LOGIQUE 3 : NOUVELLE IMAGE ---
  Future<void> _pickGalleryImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _currentImagePath = image.path;
        });
        _runFullDiagnosis(); // Relance l'analyse automatiquement
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.vert,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Diagnostique IA",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER AVEC IMAGE ---
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.vert,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 0,
                  child: Image.asset(
                    AppImages.feuille,
                    height: 80,
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          child: Image.file(
                            File(_currentImagePath),
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "Résultat du diagnostique",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _isAnalysing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _maladieDetectee,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- SECTION CONSEILS & ASSISTANT ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Conseils",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _conseilIA,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _chatCtrl,
                      onSubmitted: (_) => _askChatbot(),
                      decoration: InputDecoration(
                        hintText: _isSendingChat
                            ? "L'expert réfléchit..."
                            : "Demander à votre assistant agricole",
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        prefixIcon: IconButton(
                          icon: const Icon(
                            Icons.image_outlined,
                            color: Colors.black54,
                          ),
                          onPressed: () => _pickGalleryImage(context),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: AppColors.vert),
                          onPressed: _askChatbot,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
