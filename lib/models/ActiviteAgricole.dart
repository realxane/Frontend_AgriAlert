import 'package:agri_alert/models/enums.dart';

class ActiviteAgricole {
  final String id;
  final String userId;
  final String plantationId;

  final ActiviteType type; 
  final DateTime? doneAt;

  const ActiviteAgricole({
    required this.id,
    required this.userId,
    required this.plantationId,
    required this.type,
    this.doneAt,
  });
}
