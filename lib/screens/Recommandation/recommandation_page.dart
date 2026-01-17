import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'recommandation_detail_screen.dart';

class RecommandationsScreen extends StatelessWidget {
  const RecommandationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste de données pour les cultures
    final List<Map<String, String>> cultures = [
      {"nom": "Tomate", "image": "assets/images/tomate.jpg"},
      {"nom": "Maïs", "image": "assets/images/mais.webp"},
      {"nom": "Pommes de terre", "image": "assets/images/pomme_de_terre.webp"},
      {"nom": "Papaye", "image": "assets/images/papaye.webp"},
      {"nom": "Orange", "image": "assets/images/orange.png"},
      {"nom": "Mangue", "image": "assets/images/mangue.jpeg"},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.vert,
        elevation: 0,
        title: const Text(
          "Recommandations",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choisissez la culture à recommander",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Conteneur blanc pour la liste
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cultures.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(cultures[index]["image"]!),
                    ),
                    title: Text(
                      cultures[index]["nom"]!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // Navigation vers la page de détail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommandationDetailScreen(
                            cultureName: cultures[index]["nom"]!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
