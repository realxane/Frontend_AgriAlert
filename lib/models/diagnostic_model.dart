class DiagnosticResult {
  final String id;
  final String maladie;
  final double confidence;
  final String advice;
  final String imageUrl;

  DiagnosticResult({
    required this.id,
    required this.maladie,
    required this.confidence,
    required this.advice,
    required this.imageUrl,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      id: json['id'],
      maladie: json['maladie_detectee'],
      confidence: (json['confidence'] as num).toDouble(),
      advice: json['recommendation_ia'],
      imageUrl: json['image_url'],
    );
  }
}
