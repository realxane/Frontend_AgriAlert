class WeatherHour {
  final String time;
  final int temp;
  final int humidity;
  final int uvIndex;
  final int rain;
  final int wind;

  WeatherHour({
    required this.time,
    required this.temp,
    required this.humidity,
    required this.uvIndex,
    required this.rain,
    required this.wind,
  });
}

class WeatherDay {
  final String dayName;
  final String status;
  final List<WeatherHour> hours;

  WeatherDay({
    required this.dayName,
    required this.status,
    required this.hours,
  });
}
