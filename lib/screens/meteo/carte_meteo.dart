import 'package:agri_alert/models/model_meteo.dart';
import 'package:flutter/material.dart';

class WeatherCardDetail extends StatefulWidget {
  final WeatherDay dayData;

  const WeatherCardDetail({super.key, required this.dayData});

  @override
  State<WeatherCardDetail> createState() => _WeatherCardDetailState();
}

class _WeatherCardDetailState extends State<WeatherCardDetail> {
  int _selectedHourIndex = 0;

  @override
  Widget build(BuildContext context) {
    // On récupère les données de l'heure sélectionnée
    final currentHour = widget.dayData.hours[_selectedHourIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_outlined, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    "Mise en jour-Météo",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4FF5B), // Vert fluo "Cloudy"
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.dayData.status,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Température principale
          Text(
            "${currentHour.temp}°",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.w300,
            ),
          ),

          // Barre de dégradé de température
          _buildTempBar(currentHour.temp),
          const SizedBox(height: 20),

          // Liste horizontale des heures
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.dayData.hours.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedHourIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedHourIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white24 : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        widget.dayData.hours[index].time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),

          // Grille des détails (Humidité, UV, Pluie, Vent)
          _buildInfoGrid(currentHour),
        ],
      ),
    );
  }

  Widget _buildTempBar(int temp) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("20°", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("27°", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Container(
          height: 12,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
            ),
          ),
          child: Center(
            child: Container(
              width: 4,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(WeatherHour hour) {
    return Column(
      children: [
        Row(
          children: [
            _infoBox("Humidity", "${hour.humidity}%"),
            _infoBox("UV Index", hour.uvIndex.toString().padLeft(2, '0')),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Colors.white12),
        ),
        Row(
          children: [
            _infoBox("Rain", "${hour.rain}%"),
            _infoBox("Wind", "${hour.wind}km/h"),
          ],
        ),
      ],
    );
  }

  Widget _infoBox(String title, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
