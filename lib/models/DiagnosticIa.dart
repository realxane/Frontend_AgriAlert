class DiagnosticIa {
  final String id;
  final String userId;

  final String? imageUrl;
  final String? maladieDetectee;

  final double? confidence;
  final String? recommendationIa;

  const DiagnosticIa({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.maladieDetectee,
    this.confidence,
    this.recommendationIa,
  });
}