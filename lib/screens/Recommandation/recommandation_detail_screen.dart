import 'package:flutter/material.dart';

class RecommandationDetailScreen extends StatelessWidget {
  final String cultureName;

  const RecommandationDetailScreen({super.key, required this.cultureName});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la culture arrondie
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/images/tomateD.jpeg",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "La $cultureName est une légume cultivée pour ses fruits comestibles...",
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Conditions idéales",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Ligne des conditions (Temp, Soleil, Eau)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildConditionCard(
                  "Tem",
                  "20-30°C",
                  Icons.thermostat,
                  Colors.orange.shade100,
                ),
                _buildConditionCard(
                  "Soleil",
                  "Plein Soleil",
                  Icons.wb_sunny,
                  Colors.yellow.shade100,
                ),
                _buildConditionCard(
                  "Eau",
                  "3-4 Sémaines",
                  Icons.water_drop,
                  Colors.blue.shade100,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Besoin d'engrais cette sémaine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "Vos ${cultureName}s entrent dans une phase de forte demande. Appliquez un engrais NPK 15-15-15 pour une croissance optimale.",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 15),
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
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
