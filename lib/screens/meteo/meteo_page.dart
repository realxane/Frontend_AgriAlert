import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/models/model_meteo.dart';
import 'package:agri_alert/screens/meteo/carte_meteo.dart';
import 'package:flutter/material.dart';

// ✅ Ajout API backend météo
import 'package:agri_alert/services/weather_api.dart';

class WeatherPage extends StatefulWidget {
  final String champId;
  const WeatherPage({super.key, required this.champId});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherApi = WeatherApi();

  // Le jour actuellement affiché sur la carte
  WeatherDay? selectedDay;

  //  données 7 jours
  List<WeatherDay> _forecastDays = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // 1) today
      final todayRes = await _weatherApi.today(champId: widget.champId);

      final todayJson =
          (todayRes['today'] as Map?)?.cast<String, dynamic>() ?? {};
      final hourlyList = (todayRes['hourly'] as List?)?.cast<dynamic>() ?? [];

      // construire les hours
      final hours = hourlyList
          .map((e) => WeatherHour.fromHourlyJson(
              (e as Map).cast<String, dynamic>()))
          .toList();

      // injecter humidity/wind/uv dans toutes les heures depuis today (car hourly ne les fournit pas)
      final humidity = (todayJson['humidity'] is num)
          ? (todayJson['humidity'] as num).round()
          : 0;

      final wind = (todayJson['wind'] is num)
          ? (todayJson['wind'] as num).toDouble()
          : 0.0;

      final uv = (todayJson['uv'] is num) ? (todayJson['uv'] as num).round() : 0;

      final enrichedHours = hours.map((h) {
        return WeatherHour(
          time: h.time,
          temp: h.temp,
          humidity: humidity,
          uvIndex: uv,
          rain: h.rain,
          wind: wind,
        );
      }).toList();

      final todayDay =
          WeatherDay.fromTodayJson(todayJson, enrichedHours, dayName: "Aujourd'hui");

      // 2) forecast 7 jours
      final forecastRes =
          await _weatherApi.forecast(champId: widget.champId, days: 7);

      final daysList = (forecastRes['days'] as List?)?.cast<dynamic>() ?? [];

      final forecastDays = daysList
          .map((e) => WeatherDay.fromForecastDayJson(
              (e as Map).cast<String, dynamic>()))
          .toList();

      setState(() {
        selectedDay = todayDay;
        _forecastDays = [todayDay, ...forecastDays]; // inclure today en 1er
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          // 1. Fond vert en haut (Header)
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

          // 2. Motif de feuille en haut à droite
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Historiques des météos",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_loading) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 100),
                    ] else if (_error != null) ...[
                      Text("Erreur: $_error",
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadWeather,
                        child: const Text("Réessayer"),
                      ),
                      const SizedBox(height: 100),
                    ] else if (selectedDay != null) ...[
                      Text(
                        selectedDay!.dayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Appel du widget de la carte
                      WeatherCardDetail(
                        dayData: selectedDay!,
                        key: ValueKey(selectedDay!.dayName),
                      ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showSevenDaysForecast(),
                          child: const Text(
                            "Voir plus",
                            style: TextStyle(
                              color: Color(0xFF7B78FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FONCTION POUR VOIR LES 7 JOURS ---
  void _showSevenDaysForecast() {
    if (_forecastDays.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        // on enlève le premier (aujourd'hui) si tu veux
        final list = _forecastDays.length > 1 ? _forecastDays.sublist(1) : _forecastDays;

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Prévisions sur 7 jours",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final day = list[index];

                    final s = day.status.toLowerCase();
                    final isSunny = s.contains('clear') || s.contains('soleil') || s.contains('sun');

                    return ListTile(
                      leading: Icon(
                        isSunny ? Icons.wb_sunny : Icons.cloud,
                        color: isSunny ? Colors.orange : Colors.blueGrey,
                      ),
                      title: Text(
                        day.dayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(day.status),
                      trailing: Text(
                        day.max != null ? "${day.max!.round()}°" : "--",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Ici, les days n'ont pas d'heures détaillées -> on ne remplace pas la carte
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
