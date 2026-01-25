class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String icon;
  final DateTime date;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      // On convertit l'ID en String par sécurité
      id: json['id'].toString(),
      title: json['title'] ?? 'Alerte',
      message: json['message'] ?? '',
      icon: json['icon'] ?? 'assets/images/notification_default.png',
      // On parse le created_at de Laravel
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
