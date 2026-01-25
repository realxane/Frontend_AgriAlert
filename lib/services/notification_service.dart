import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Demander la permission (iOS/Android 13+)
    await _fcm.requestPermission();

    // 2. Initialiser les notifications locales pour le mode "Foreground" (App ouverte)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // 3. Écouter les notifications quand l'app est ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  static void _showLocalNotification(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', // ID du canal
          'Alertes Agricoles', // Nom du canal
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Fonction pour récupérer le token et l'envoyer à  Laravel
  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
