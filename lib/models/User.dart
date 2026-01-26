import 'enums.dart';

class User {
  final String id;
  final String nom;
  final String telephone;
  final String email;

  /// Forcé à agriculteur (mobile uniquement)
  final Role role;

  final bool isActive;

  final String? photoUrl;
  final String? fcmToken;

  const User({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.email,
    this.isActive = true,
    this.photoUrl,
    this.fcmToken,
  }) : role = Role.agriculteur;
}
