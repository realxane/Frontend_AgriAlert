class DiagnosticResult {
  final String id;
  final String maladie;
  final double confidence;
  final String advice;
  final String imageUrl;

  final String? createdAt;

  DiagnosticResult({
    required this.id,
    required this.maladie,
    required this.confidence,
    required this.advice,
    required this.imageUrl,
    this.createdAt,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      id: (json['id'] ?? '').toString(),
      maladie: (json['maladie_detectee'] ?? '').toString(),
      confidence: (json['confidence'] is num) ? (json['confidence'] as num).toDouble() : 0.0,
      advice: (json['recommendation_ia'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      createdAt: json['created_at']?.toString(), 
    );
  }

  // Format "17/12/2025"
  String get createdAtShort {
    final v = createdAt;
    if (v == null || v.isEmpty) return '';
    try {
      final dt = DateTime.parse(v);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      return '$dd/$mm/$yyyy';
    } catch (_) {
      // si Laravel renvoie un format non ISO
      if (v.length >= 10) {
        final s = v.substring(0, 10); // yyyy-mm-dd
        final parts = s.split('-');
        if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return v;
    }
  }
}
