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

  bool get _isToday {
    return widget.dayData.dayName.trim().toLowerCase().contains("aujourd");
  }

  @override
  void didUpdateWidget(covariant WeatherCardDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    //  Si on change de jour, on revient à la 1ère heure
    if (oldWidget.dayData.dayName != widget.dayData.dayName) {
      _selectedHourIndex = 0;
    }
    //  Sécurité : si la liste d'heures a diminué
    if (widget.dayData.hours.isNotEmpty &&
        _selectedHourIndex >= widget.dayData.hours.length) {
      _selectedHourIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dayData.hours.isEmpty) {
      //  Cas sécurité : si dayData n'a pas d'heures (ex: forecast 7 jours)
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          "Pas de détails disponibles pour ce jour.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // ✅ Pour les autres jours que "Aujourd'hui", on force l'affichage sur la 1ère entrée
    final int safeIndex = _isToday ? _selectedHourIndex : 0;

    // On récupère les données de l'heure sélectionnée
    final currentHour = widget.dayData.hours[safeIndex];

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
                  color: const Color(0xFFD4FF5B),
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

          // Température principale (temp est un double maintenant)
          Text(
            "${currentHour.temp.round()}°",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.w300,
            ),
          ),

          // Barre de dégradé de température
          _buildTempBar(currentHour.temp.round()),
          const SizedBox(height: 20),

          // ✅ Liste horizontale des heures UNIQUEMENT pour Aujourd'hui
          if (_isToday) ...[
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
                          widget.dayData.hours[index].time, // ✅ "07:40"
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
          ] else ...[
            // ✅ Pas d'heures pour forecast
            const SizedBox(height: 10),
          ],

          // Grille des détails (Humidité, UV, Pluie, Vent)
          _buildInfoGrid(currentHour),
        ],
      ),
    );
  }

  Widget _buildTempBar(int temp) {
    //  Ici c'est une barre visuelle, on peut la rendre dynamique plus tard.
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
            _infoBox("Wind", "${hour.wind.round()}km/h"),
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
