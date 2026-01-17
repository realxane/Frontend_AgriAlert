import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedTheme = "Claire";

  // Dialogue de déconnexion personnalisé (Annuler / Confirmer)
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Voulez-vous vraiment vous déconnecter ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    "Annuler",
                    () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDialogButton("Confirmer", () {
                    // Logique de déconnexion
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE2F9B8), // Vert très clair
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        // Correction 1 : On force le scroll pour les petits écrans
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER VERT AVEC PHOTO ET NOM ---
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 30,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.vert,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Mon Profil",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage(AppImages.agriculteur),
                          ),
                          const SizedBox(width: 15),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Vieux Maiga",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Gao, Mali",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton Modifier Profil
                Positioned(
                  bottom: 15,
                  right: 20,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/modifie_profil_user');
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Modifier Profil"),
                  ),
                ),
                // Image feuille en haut à droite
                Positioned(
                  top: 10,
                  right: 0,
                  child: Image.asset(
                    AppImages.feuille,
                    height: 80,
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION RÉSUMÉ ---
                  const Text(
                    "Résumé du champ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(AppImages.champ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            "4 cultures, Dernier diag: 2jours",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 15,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/modifie_champ_page',
                              );
                            },
                            child: const Text(
                              "Modifier champ",
                              style: TextStyle(
                                color: Color(0xFF9FA8DA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- LISTE DES PARAMÈTRES ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Unité"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "m2",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text("Notification"),
                          trailing: Switch(
                            value: _notificationsEnabled,
                            activeColor: Colors.white,
                            activeTrackColor: AppColors.vert,
                            onChanged: (v) =>
                                setState(() => _notificationsEnabled = v),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text("Theme"),
                          trailing: DropdownButton<String>(
                            value: _selectedTheme,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.unfold_more, size: 18),
                            items: ["Claire", "Sombre"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedTheme = v!),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          onTap: _showLogoutDialog,
                          title: const Text("Se Déconnecter"),
                          trailing: const Icon(
                            Icons.exit_to_app,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
