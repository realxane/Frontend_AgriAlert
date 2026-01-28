import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/orange_button.dart';
import '../../widgets/auth_text_field.dart';
import '../../config/app_config.dart';
import '../../services/api_client.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ApiClient _apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
  final ProfileService _profileService =
      ProfileService(); // Instance du service dédié
  final _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String? _currentImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 1. Charger les données actuelles (Lecture simple JSON)
  Future<void> _loadCurrentUserData() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await _apiClient.get(
        '/api/profile/me',
        headers: {'Authorization': 'Bearer $token'},
      );

      final user = response['user'];
      setState(() {
        _nameController.text = user['nom'] ?? "";
        _phoneController.text = user['telephone'] ?? "";
        _emailController.text = user['email'] ?? "";
        _currentImageUrl = user['photo_url'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement profil: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. Sélectionner une image dans la galerie
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // 3. Sauvegarder les modifications via ProfileService (Gestion Multipart)
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'access_token');

      if (token == null) {
        throw Exception("Session expirée, veuillez vous reconnecter.");
      }

      // Utilisation du service dédié pour gérer l'image et le texte
      await _profileService.updateProfile(
        token: token,
        nom: _nameController.text,
        telephone: _phoneController.text,
        email: _emailController.text,
        image: _image,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Retour avec succès pour rafraîchir l'écran précédent
      }
    } catch (e) {
      debugPrint("Erreur mise à jour: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER VERT ---
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 50, bottom: 30),
                  decoration: BoxDecoration(
                    color: AppColors.vert,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Modifier profil",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // PHOTO DE PROFIL DYNAMIQUE
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundImage: _image != null
                              ? FileImage(_image!) as ImageProvider
                              : (_currentImageUrl != null
                                        ? NetworkImage(_currentImageUrl!)
                                        : AssetImage(AppImages.agriculteur))
                                    as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            "Changer la photo",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: -5,
                  child: Image.asset(
                    AppImages.feuille,
                    height: 90,
                    opacity: const AlwaysStoppedAnimation(0.4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- FORMULAIRE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("   Nom", style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _nameController,
                    hintText: "Votre nom",
                  ),

                  const SizedBox(height: 20),

                  const Text("   Téléphone", style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _phoneController,
                    hintText: "+223 xxxxxxx",
                  ),

                  const SizedBox(height: 20),

                  const Text("   Email", style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _emailController,
                    hintText: "vieuxmaiga@gmail.com",
                  ),

                  const SizedBox(height: 40),

                  OrangeButton(label: "Sauvegarder", onPressed: _updateProfile),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
