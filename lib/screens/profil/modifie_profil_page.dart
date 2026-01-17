import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../widgets/orange_button.dart';
import '../../widgets/auth_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Fonction pour changer la photo via la galerie
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER VERT (Contient tout le haut) ---
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
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // PHOTO DE PROFIL
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundImage: _image != null
                              ? FileImage(_image!) as ImageProvider
                              : AssetImage(AppImages.agriculteur),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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

                //  IMAGE DE LA FEUILLE en Haut à droite
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

            // --- FORMULAIRE (CHAMPS DE TEXTE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("   Nom", style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  const AuthTextField(hintText: "Vieux Maiga"),

                  const SizedBox(height: 20),

                  const Text("   mot de passe", style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  const AuthTextField(hintText: "********", obscureText: true),

                  const SizedBox(height: 20),

                  const Text("   Email", style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  const AuthTextField(hintText: "vieuxmaiga@gmail.com"),

                  const SizedBox(height: 40),

                  //utiliser le wiget boutton orange
                  OrangeButton(
                    label: "Sauvegarder",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
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
