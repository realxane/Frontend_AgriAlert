import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/models/model_meteo.dart';
import 'package:agri_alert/screens/meteo/carte_meteo.dart';
import 'package:flutter/material.dart';

//  Ajout API backend météo
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

  bool _isToday(WeatherDay d) {
    return d.dayName.trim().toLowerCase().contains("aujourd");
  }

  WeatherDay _ensureDailyHasSummaryHour(WeatherDay day) {
    //  Si c’est un jour forecast et qu’il n’a pas d’heures, on crée un résumé.
    if (_isToday(day)) return day;
    if (day.hours.isNotEmpty) return day;

    final double tempResume = day.max ?? day.min ?? 0.0;

    final summaryHour = WeatherHour(
      time: "Journée", //  pas d’horaires pour les autres jours
      temp: tempResume,
      humidity: day.humidity ?? 0,
      uvIndex: 0, // pas dispo dans forecast (tu peux améliorer si tu ajoutes l’API)
      rain: day.pop ?? 0, // déjà en % dans ton modèle (pop)
      wind: day.wind ?? 0.0,
    );

    return WeatherDay(
      dayName: day.dayName,
      status: day.status,
      hours: [summaryHour],
      date: day.date,
      min: day.min,
      max: day.max,
      humidity: day.humidity,
      wind: day.wind,
      pop: day.pop,
    );
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
                (e as Map).cast<String, dynamic>(),
              ))
          .toList();

      // injecter humidity/wind/uv dans toutes les heures depuis today (car hourly ne les fournit pas)
      final humidity = (todayJson['humidity'] is num)
          ? (todayJson['humidity'] as num).round()
          : 0;

      final wind = (todayJson['wind'] is num)
          ? (todayJson['wind'] as num).toDouble()
          : 0.0;

      final uv =
          (todayJson['uv'] is num) ? (todayJson['uv'] as num).round() : 0;

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

      final todayDay = WeatherDay.fromTodayJson(
        todayJson,
        enrichedHours,
        dayName: "Aujourd'hui",
      );

      // 2) forecast 7 jours
      final forecastRes =
          await _weatherApi.forecast(champId: widget.champId, days: 7);

      final daysList = (forecastRes['days'] as List?)?.cast<dynamic>() ?? [];

      final forecastDaysRaw = daysList
          .map((e) => WeatherDay.fromForecastDayJson(
                (e as Map).cast<String, dynamic>(),
              ))
          .toList();

      //  IMPORTANT : on transforme chaque jour forecast en “jour avec 1 heure résumé”
      final forecastDays = forecastDaysRaw.map(_ensureDailyHasSummaryHour).toList();

      setState(() {
        selectedDay = todayDay; // today garde les heures
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
        final list = _forecastDays; //  on garde Aujourd'hui dedans

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
                    final isSunny = s.contains('clear') ||
                        s.contains('soleil') ||
                        s.contains('sun');

                    final isSelected = (selectedDay?.dayName == day.dayName);

                    return ListTile(
                      leading: Icon(
                        isSunny ? Icons.wb_sunny : Icons.cloud,
                        color: isSunny ? Colors.orange : Colors.blueGrey,
                      ),
                      title: Text(
                        day.dayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.vert : Colors.black,
                        ),
                      ),
                      subtitle: Text(day.status),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: AppColors.vert, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            day.max != null ? "${day.max!.round()}°" : "--",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // ✅ Maintenant : même les jours forecast ont un “résumé” => la carte s’affiche
                        setState(() => selectedDay = _ensureDailyHasSummaryHour(day));
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
