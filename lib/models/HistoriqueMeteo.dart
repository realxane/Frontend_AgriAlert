import 'package:agri_alert/models/enums.dart';

class HistoriqueMeteo {
  final String id;

  final String regionId;
  final String? champId;

  final DateTime date;
  final double? temperature;
  final double? precipitation;
  final double? humidite;

  final SourceMeteo source; 

  const HistoriqueMeteo({
    required this.id,
    required this.regionId,
    required this.date,
    this.champId,
    this.temperature,
    this.precipitation,
    this.humidite,
  }) : source = SourceMeteo.openWeather;
}