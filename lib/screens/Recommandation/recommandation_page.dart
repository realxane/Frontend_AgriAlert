import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import 'recommandation_detail_screen.dart';

class RecommandationsScreen extends StatelessWidget {
  const RecommandationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> cultures = [
      {"nom": "Tomate", "image": "assets/images/tomate.jpg"},
      {"nom": "Maïs", "image": "assets/images/mais.webp"},
      {"nom": "Pommes de terre", "image": "assets/images/pomme_de_terre.webp"},
      {"nom": "Papaye", "image": "assets/images/papaye.webp"},
      {"nom": "Orange", "image": "assets/images/orange.png"},
      {"nom": "Mangue", "image": "assets/images/mangue.jpeg"},
      {"nom": "Oignon", "image": "assets/images/oignon.jpg"},
      {"nom": "Piment", "image": "assets/images/piment.jpg"},
      {"nom": "Papaye", "image": "assets/images/papaye.webp"},
      {"nom": "Orange", "image": "assets/images/orange.png"},
      {"nom": "Mangue", "image": "assets/images/mangue.jpeg"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          // 1. Fond vert fixe
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              color: AppColors.vert,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. Motif feuille fixe
          Positioned(
            top: 10,
            right: 0,
            child: Image.asset(
              AppImages.feuille,
              height: 80,
              opacity: const AlwaysStoppedAnimation(0.5),
            ),
          ),

          // 3. Contenu de la page
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PARTIE FIXE ---
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Recommandations",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Choisissez la culture à recommander",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- PARTIE DÉFILANTE (La liste uniquement) ---
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cultures.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    indent: 20,
                                    endIndent: 20,
                                  ),
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: AssetImage(
                                      cultures[index]["image"]!,
                                    ),
                                  ),
                                  title: Text(
                                    cultures[index]["nom"]!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecommandationDetailScreen(
                                              cultureName:
                                                  cultures[index]["nom"]!,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        // Espace en bas pour éviter que la liste touche la barre de navigation
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
