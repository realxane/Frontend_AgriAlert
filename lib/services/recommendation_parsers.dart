import 'package:agri_alert/models/Culture.dart';
import 'package:agri_alert/models/recommandation.dart';
import 'package:agri_alert/models/enums.dart';

// ---------- CultureModel ----------
NomCulture _parseNomCulture(String v) {

  switch (v.toLowerCase()) {
    case 'pomme de terre':
      return NomCulture.pommeDeTerre;
    case 'pommedeterre':
      return NomCulture.pommeDeTerre;
    case 'pomme_de_terre':
      return NomCulture.pommeDeTerre;
    case 'citron':
      return NomCulture.citron;
    case 'orange':
      return NomCulture.orange;
    case 'mangue':
      return NomCulture.mangue;
    case 'poivre':
      return NomCulture.poivre;
    case 'fraise':
      return NomCulture.fraise;
    case 'raisin':
      return NomCulture.raisin;
    case 'papaye':
      return NomCulture.papaye;
    case 'pomme':
      return NomCulture.pomme;
    case 'tomate':
    default:
      return NomCulture.tomate;
  }
}

Culture cultureFromJson(Map<String, dynamic> json) {
  // Ton backend renvoie: nom => "Tomate"
  // ou parfois {nom:{value:"Tomate"}} selon cast. On gère les 2.
  final rawNom = (json['nom'] is Map)
      ? (json['nom']['value']?.toString() ?? '')
      : (json['nom']?.toString() ?? '');

  return Culture(
    id: json['id'].toString(),
    nom: _parseNomCulture(rawNom),
    cycleDate: (json['cycle_date'] is num) ? (json['cycle_date'] as num).round() : null,
    tempIdealeMin: (json['temp_ideale_min'] is num) ? (json['temp_ideale_min'] as num).round() : null,
    tempIdealeMax: (json['temp_ideale_max'] is num) ? (json['temp_ideale_max'] as num).round() : null,
    ensoleillement: json['ensoleillement']?.toString(),
    eau: json['eau']?.toString(),
    imageUrl: json['image_url']?.toString(),
    description: json['description']?.toString(),
  );
}

// ---------- Recommandation ----------
Saison? _parseSaisonNullable(dynamic v) {
  if (v == null) return null;
  final s = v.toString().toLowerCase();
  if (s.contains('hivernage')) return Saison.hivernage;
  return Saison.saisonSeche;
}

/// Dans ton modèle `Recommandation`, tu as Saison / regionId non null.
/// Or dans la DB tu as region_id nullable et saison nullable.
/// Pour rester compatible avec TON modèle, on met des valeurs par défaut si null.
Recommandation recommandationFromJson(
  Map<String, dynamic> json, {
  required String cultureId,
}) {
  final saison = _parseSaisonNullable(json['saison']) ?? Saison.saisonSeche;
  final regionId = (json['region_id'] ?? '').toString();

  return Recommandation(
    id: json['id'].toString(),
    titre: json['titre']?.toString() ?? '',
    contenu: json['contenu']?.toString() ?? '',
    saison: saison,
    regionId: regionId,
    cultureId: cultureId,
    activiteType: json['activite_type']?.toString(),
    minJour: (json['min_jour'] is num) ? (json['min_jour'] as num).round() : null,
    maxJour: (json['max_jour'] is num) ? (json['max_jour'] as num).round() : null,
    weatherRules: (json['weather_rules'] is Map) ? (json['weather_rules'] as Map).cast<String, dynamic>() : null,
    priorite: (json['priorite'] is num) ? (json['priorite'] as num).round() : 100,
  );
}
