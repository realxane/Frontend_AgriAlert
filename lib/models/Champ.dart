class Champ {
  final String id;
  final String userId;

  final String nom;
  final double latitude;
  final double longitude;
  final double aire;

  final String regionId;

  const Champ({
    required this.id,
    required this.userId,
    required this.nom,
    required this.regionId,
    required this.latitude,
    required this.longitude,
    required this.aire,
  });
}
