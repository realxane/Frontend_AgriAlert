import 'package:agri_alert/models/enums.dart';

class Culture {
  final String id;

  final NomCulture nom; 
  final int? cycleDate;

  final int? tempIdealeMin;
  final int? tempIdealeMax;

  final String? ensoleillement;
  final String? eau;

  final String? imageUrl;
  final String? description;

  const Culture({
    required this.id,
    required this.nom,
    this.cycleDate,
    this.tempIdealeMin,
    this.tempIdealeMax,
    this.ensoleillement,
    this.eau,
    this.imageUrl,
    this.description,
  });
}