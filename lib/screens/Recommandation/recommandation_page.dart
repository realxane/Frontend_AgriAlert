import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import 'recommandation_detail_screen.dart';

//  backend + parsers
import 'package:agri_alert/services/recommendation_api.dart';
import 'package:agri_alert/services/recommendation_parsers.dart';
import 'package:agri_alert/models/Culture.dart';

class RecommandationsScreen extends StatefulWidget {
  const RecommandationsScreen({super.key});

  @override
  State<RecommandationsScreen> createState() => _RecommandationsScreenState();
}

class _RecommandationsScreenState extends State<RecommandationsScreen> {
  final _api = RecommendationApi();

  bool _loading = true;
  String? _error;

  String? _champId;
  List<Culture> _cultures = [];

  @override
  void initState() {
    super.initState();
    _loadUserCultures();
  }

  Future<void> _loadUserCultures() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // 1) champs user
      final champsRes = await _api.getMyChamps();
      final raw = (champsRes['data'] ?? champsRes['champs'] ?? champsRes);

      if (raw is! List || raw.isEmpty) {
        throw Exception("Aucun champ trouvé.");
      }

      final champId = raw[0]['id'].toString();
      _champId = champId;

      // 2) champ detail (doit contenir plantations + culture)
      final champRes = await _api.getChamp(champId);

      final champ = (champRes['champ'] ?? champRes['data'] ?? champRes) as Map;

      final plantations = (champ['plantations'] as List? ?? []);


      // 3) cultures uniques via plantations.culture
      final Map<String, Culture> unique = {};

      for (final p in plantations) {
        final pp = (p as Map).cast<String, dynamic>();

        final cultureJson = (pp['culture'] as Map?)?.cast<String, dynamic>();
        if (cultureJson != null) {
          final c = cultureFromJson(cultureJson);
          unique[c.id] = c;
        }
      }

      if (unique.isEmpty) {
        throw Exception(
          "Aucune culture trouvée. Vérifie que /api/champs/{id} renvoie plantations.culture.",
        );
      }

      setState(() {
        _cultures = unique.values.toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // image locale si imageUrl null
  String _fallbackAsset(String nom) {
    final n = nom.toLowerCase();
    if (n.contains('tomate')) return "assets/images/tomate.jpg";
    if (n.contains('maïs') || n.contains('mais')) return "assets/images/mais.webp";
    if (n.contains('pomme')) return "assets/images/pomme_de_terre.webp";
    if (n.contains('fraise')) return "assets/images/fraise.jpg";   
    if (n.contains('raisin')) return "assets/images/raisin.jpg";   

    if (n.contains('pomme de terre') || n.contains('pomme_de_terre')) {
      return "assets/images/pomme_de_terre.webp";
    }
    if (n.contains('papaye')) return "assets/images/papaye.webp";
    if (n.contains('orange')) return "assets/images/orange.png";
    if (n.contains('mangue')) return "assets/images/mangue.jpeg";
    if (n.contains('citron')) return "assets/images/citron.png";
    if (n.contains('poivre') || n.contains('piment')) return "assets/images/piment.jpg";
    return "assets/images/tomate.jpg";
  }

  String _cultureLabel(Culture c) => c.nom.name; // ex: "tomate"
  // Si tu veux "Tomate": fais une map, mais je laisse simple.

  @override
  Widget build(BuildContext context) {
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

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : (_error != null)
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Erreur : $_error",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _loadUserCultures,
                                      child: const Text("Réessayer"),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
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
                                        itemCount: _cultures.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(height: 1, indent: 20, endIndent: 20),
                                        itemBuilder: (context, index) {
                                          final c = _cultures[index];

                                          final nomText = _cultureLabel(c);
                                          final hasNetwork = (c.imageUrl != null && c.imageUrl!.isNotEmpty);

                                          final imgProvider = hasNetwork
                                              ? NetworkImage(c.imageUrl!)
                                              : AssetImage(_fallbackAsset(nomText)) as ImageProvider;

                                          return ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            leading: CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Colors.grey[200],
                                              backgroundImage: imgProvider,
                                            ),
                                            title: Text(
                                              nomText,
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
                                              if (_champId == null) return;

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RecommandationDetailScreen(
                                                    champId: _champId!,
                                                    culture: c,
                                                    cultureImageProvider: imgProvider,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
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
