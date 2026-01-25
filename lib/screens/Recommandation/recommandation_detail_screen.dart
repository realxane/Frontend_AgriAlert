import 'package:flutter/material.dart';
import 'package:agri_alert/models/Culture.dart';
import 'package:agri_alert/models/recommandation.dart';
import 'package:agri_alert/services/recommendation_api.dart';
import 'package:agri_alert/services/recommendation_parsers.dart';

class RecommandationDetailScreen extends StatefulWidget {
  final String champId;
  final Culture culture;
  final ImageProvider cultureImageProvider;

  const RecommandationDetailScreen({
    super.key,
    required this.champId,
    required this.culture,
    required this.cultureImageProvider,
  });

  @override
  State<RecommandationDetailScreen> createState() => _RecommandationDetailScreenState();
}

class _RecommandationDetailScreenState extends State<RecommandationDetailScreen> {
  final _api = RecommendationApi();

  bool _loading = true;
  String? _error;

  List<Recommandation> _recs = [];

  @override
  void initState() {
    super.initState();
    _loadRecs();
  }

  Future<void> _loadRecs() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final res = await _api.recommendationsByCulture(
        champId: widget.champId,
        cultureId: widget.culture.id,
      );

      // res = { culture:{...}, contexte:{...}, recommandations:[...] }
      final recList = (res['recommandations'] as List? ?? []);

      final parsed = recList.map((e) {
        return recommandationFromJson(
          (e as Map).cast<String, dynamic>(),
          cultureId: widget.culture.id,
        );
      }).toList();

      // tri optionnel : priorité croissante si tu veux
      parsed.sort((a, b) => a.priorite.compareTo(b.priorite));

      setState(() {
        _recs = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _cultureLabel(Culture c) => c.nom.name;

  @override
  Widget build(BuildContext context) {
    final cultureName = _cultureLabel(widget.culture);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          cultureName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Erreur: $_error",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadRecs,
                          child: const Text("Réessayer"),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(cultureName),
    );
  }

  Widget _buildContent(String cultureName) {
    final c = widget.culture;

    final tempValue = (c.tempIdealeMin != null && c.tempIdealeMax != null)
        ? "${c.tempIdealeMin}-${c.tempIdealeMax}°C"
        : "--";

    final soleilValue = c.ensoleillement ?? "--";
    final eauValue = c.eau ?? "--";
    final description = c.description ?? "Informations sur $cultureName.";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image(
              image: widget.cultureImageProvider,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          Text(description, style: const TextStyle(fontSize: 15, height: 1.5)),

          const SizedBox(height: 30),
          const Center(
            child: Text(
              "Conditions idéales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildConditionCard(
                "Tem",
                tempValue,
                Icons.thermostat,
                Colors.orange.shade100,
              ),
              _buildConditionCard(
                "Soleil",
                soleilValue,
                Icons.wb_sunny,
                Colors.yellow.shade100,
              ),
              _buildConditionCard(
                "Eau",
                eauValue,
                Icons.water_drop,
                Colors.blue.shade100,
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Text(
            "Recommandations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (_recs.isEmpty)
            const Text("Aucune recommandation disponible.")
          else
            for (final r in _recs) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r.contenu,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  // Widget pour les petites cartes de conditions
  Widget _buildConditionCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.black87),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
