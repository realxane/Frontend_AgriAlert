import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/models/model_meteo.dart';
import 'package:agri_alert/screens/meteo/carte_meteo.dart';
import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Le jour actuellement affiché sur la carte
  late WeatherDay selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = forecastData[0]; // Initialisation sur le premier jour
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
              color: AppColors.vert, // Couleur verte de la maquette
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
              // Permet de faire défiler toute la page
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
                          color: Colors.black, // Texte visible sur le vert
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      selectedDay.dayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Appel du widget de la carte
                    WeatherCardDetail(
                      dayData: selectedDay,
                      key: ValueKey(selectedDay.dayName),
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
                    // Espace supplémentaire en bas pour le confort
                    const SizedBox(height: 100),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet au panneau de mieux s'adapter
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          // Limite la hauteur à 70% de l'écran pour garder le style
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
                // Utilisation de Expanded au lieu de Flexible pour la liste
                child: ListView.builder(
                  itemCount: forecastData.length,
                  itemBuilder: (context, index) {
                    final day = forecastData[index];
                    return ListTile(
                      leading: Icon(
                        day.status == "Sunny" ? Icons.wb_sunny : Icons.cloud,
                        color: day.status == "Sunny"
                            ? Colors.orange
                            : Colors.blueGrey,
                      ),
                      title: Text(
                        day.dayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(day.status),
                      trailing: Text(
                        "${day.hours[0].temp}°",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(
                          () => selectedDay = day,
                        ); // Met à jour la page principale
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

// --- TES DONNÉES (NON MODIFIÉES) ---
final List<WeatherDay> forecastData = [
  WeatherDay(
    dayName: "Aujourd'hui",
    status: "Cloudly",
    hours: [
      WeatherHour(
        time: "07.40AM",
        temp: 20,
        humidity: 85,
        uvIndex: 2,
        rain: 15,
        wind: 12,
      ),
      WeatherHour(
        time: "08.00AM",
        temp: 24,
        humidity: 80,
        uvIndex: 4,
        rain: 12,
        wind: 18,
      ),
      WeatherHour(
        time: "10.00AM",
        temp: 26,
        humidity: 70,
        uvIndex: 6,
        rain: 5,
        wind: 15,
      ),
    ],
  ),
  WeatherDay(
    dayName: "Mardi",
    status: "Rainy",
    hours: [
      WeatherHour(
        time: "08.00AM",
        temp: 21,
        humidity: 90,
        uvIndex: 2,
        rain: 70,
        wind: 22,
      ),
      WeatherHour(
        time: "10.00AM",
        temp: 23,
        humidity: 85,
        uvIndex: 3,
        rain: 50,
        wind: 18,
      ),
      WeatherHour(
        time: "12.00PM",
        temp: 25,
        humidity: 80,
        uvIndex: 4,
        rain: 30,
        wind: 15,
      ),
      WeatherHour(
        time: "02.00PM",
        temp: 27,
        humidity: 75,
        uvIndex: 5,
        rain: 20,
        wind: 10,
      ),
      WeatherHour(
        time: "04.00PM",
        temp: 26,
        humidity: 80,
        uvIndex: 4,
        rain: 25,
        wind: 12,
      ),
    ],
  ),
  WeatherDay(
    dayName: "Mercredi",
    status: "Sunny",
    hours: [
      WeatherHour(
        time: "08.00AM",
        temp: 27,
        humidity: 55,
        uvIndex: 7,
        rain: 0,
        wind: 12,
      ),
    ],
  ),
  WeatherDay(
    dayName: "Jeudi",
    status: "Cloudly",
    hours: [
      WeatherHour(
        time: "08.00AM",
        temp: 22,
        humidity: 75,
        uvIndex: 5,
        rain: 10,
        wind: 14,
      ),
    ],
  ),
];
