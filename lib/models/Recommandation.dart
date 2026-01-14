import 'enums.dart';

class Recommandation {
  final String id;

  final String titre;
  final String contenu;

  final Saison saison;
  final String regionId;
  final String cultureId;

  final String? activiteType;

  final int? minJour;
  final int? maxJour;

  final Map<String, dynamic>? weatherRules;
  final int priorite;

  const Recommandation({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.saison,
    required this.regionId,
    required this.cultureId,
    required this.priorite,
    this.activiteType,
    this.minJour,
    this.maxJour,
    this.weatherRules,
  });
}
