import 'package:agri_alert/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../config/app_config.dart';
import '../../services/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? userData;
  Map<String, dynamic>? champData;
  bool _isLoading = true;

  bool _notificationsEnabled = true;
  String _selectedTheme = "Claire";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // --- LOGIQUE API ---
  Future<void> _fetchProfileData() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
        return;
      }

      final response = await _apiClient.get(
        '/api/profile/me',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) {
        setState(() {
          userData = response['user'];
          champData = response['champ'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur profil : $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await _apiClient
            .post('/api/logout', headers: {'Authorization': 'Bearer $token'})
            .timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint("Erreur logout : $e");
    } finally {
      await _storage.delete(key: 'access_token');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.connecter,
          (route) => false,
        );
      }
    }
  }

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
                    Navigator.pop(context);
                    _handleLogout();
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
        backgroundColor: const Color(0xFFE2F9B8),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER AVEC DESIGN vert ---
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
                            backgroundColor: Colors.grey[300],
                            backgroundImage: (userData?['photo_url'] != null)
                                ? NetworkImage(userData!['photo_url'])
                                : AssetImage(AppImages.agriculteur)
                                      as ImageProvider,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData?['nom'] ?? "Utilisateur",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                champData?['region_name'] ?? "Région inconnue",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // L'IMAGE DE LA FEUILLE
                Positioned(
                  top: 10,
                  right: 0,
                  child: Image.asset(
                    AppImages.feuille,
                    height: 80,
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                ),
                // BOUTON MODIFIER
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
                      Navigator.pushNamed(
                        context,
                        '/modifie_profil_user',
                      ).then((_) => _fetchProfileData());
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Modifier Profil"),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        Center(
                          child: Text(
                            "${champData?['type_culture'] ?? 'Non définie'}\nAire: ${champData?['aire'] ?? '0'} m2",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                              ).then((_) => _fetchProfileData());
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
                        _buildListTile("Unité", trailing: "m2"),
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
                            items: ["Claire", "Sombre"]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(
                                      v,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
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

  Widget _buildListTile(String title, {required String trailing}) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailing, style: TextStyle(color: Colors.grey[600])),
          const Icon(Icons.chevron_right, color: Colors.blue),
        ],
      ),
    );
  }
}
