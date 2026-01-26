class WeatherHour {
  final String time;        // "07:40"
  final double temp;        // 20.15
  final int humidity;       // 81 (on le mettra depuis today)
  final int uvIndex;        // 04 (today)
  final int rain;           // % 0..100
  final double wind;        // 18.0

  WeatherHour({
    required this.time,
    required this.temp,
    required this.humidity,
    required this.uvIndex,
    required this.rain,
    required this.wind,
  });

  factory WeatherHour.fromHourlyJson(Map<String, dynamic> json) {
    // hourly => { time:"07:40", temp:..., pop:0.2 }
    final pop = (json['pop'] is num) ? (json['pop'] as num).toDouble() : 0.0;
    final rainPercent = (pop * 100).round();

    return WeatherHour(
      time: (json['time'] ?? '').toString(),
      temp: (json['temp'] is num) ? (json['temp'] as num).toDouble() : 0.0,
      humidity: 0, // pas dans hourly, on remplira depuis today
      uvIndex: 0,  // pas dans hourly, on remplira depuis today
      rain: rainPercent,
      wind: 0.0,   // pas dans hourly
    );
  }
}

class WeatherDay {
  final String dayName;     // "Aujourd'hui" ou "mar. 07"
  final String status;      // "Cloudly" / "Sunny" / ...
  final List<WeatherHour> hours;

  // Pour la prévision 7 jours
  final String? date;       // "2026-01-08"
  final double? min;
  final double? max;
  final int? humidity;
  final double? wind;
  final int? pop;           // % 0..100

  WeatherDay({
    required this.dayName,
    required this.status,
    required this.hours,
    this.date,
    this.min,
    this.max,
    this.humidity,
    this.wind,
    this.pop,
  });

  factory WeatherDay.fromTodayJson(Map<String, dynamic> todayJson, List<WeatherHour> hours, {String dayName = "Aujourd'hui"}) {
    return WeatherDay(
      dayName: dayName,
      status: (todayJson['desc'] ?? 'Cloudly').toString(),
      hours: hours,
    );
  }

  factory WeatherDay.fromForecastDayJson(Map<String, dynamic> d) {
    final pop = (d['pop'] is num) ? (d['pop'] as num).toDouble() : 0.0;
    return WeatherDay(
      dayName: (d['label'] ?? d['date'] ?? '').toString(),
      status: (d['desc'] ?? 'Cloudly').toString(),
      hours: const [],
      date: d['date']?.toString(),
      min: (d['min'] is num) ? (d['min'] as num).toDouble() : null,
      max: (d['max'] is num) ? (d['max'] as num).toDouble() : null,
      humidity: (d['humidity'] is num) ? (d['humidity'] as num).round() : null,
      wind: (d['wind'] is num) ? (d['wind'] as num).toDouble() : null,
      pop: (pop * 100).round(),
    );
  }
}
