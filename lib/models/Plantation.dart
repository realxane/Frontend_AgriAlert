class Plantation {
  final String id;
  final String champId;
  final String cultureId;

  final DateTime? dateDebut; 
  final DateTime? dateFin;

  const Plantation({
    required this.id,
    required this.champId,
    required this.cultureId,
    this.dateDebut,
    this.dateFin,
  });
}