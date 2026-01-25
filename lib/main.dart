import 'package:agri_alert/routes/app_routes.dart';
import 'package:agri_alert/screens/Recommandation/recommandation_page.dart';
import 'package:agri_alert/screens/auth/forgot_password_screen.dart';
import 'package:agri_alert/screens/auth/new_password_screen.dart';
import 'package:agri_alert/screens/meteo/meteo_page.dart';
import 'package:agri_alert/screens/profil/modifie_champ_page.dart';
import 'package:agri_alert/screens/profil/modifie_profil_page.dart';
import 'package:agri_alert/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/champ_create_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/notification/notification_screen.dart';

import 'package:camera/camera.dart';
import 'screens/IA/scanner_page.dart';

// --- AJOUT 1 : La clé globale pour naviguer sans contexte ---
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notification reçue en arrière-plan : ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCjYeTaw4MNcPDU29XMrNfoeRM1EyHsLyw",
      appId: "1:116138252894:android:bb470a21c1484b3ddc72cf",
      messagingSenderId: "116138252894",
      projectId: "agrialert-15695",
      storageBucket: "agrialert-15695.firebasestorage.app",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushNotificationService.initialize();

  // --- AJOUT 2 : Écouter le clic sur la notification quand l'app est en arrière-plan ---
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Clic sur notification détecté !");
    navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
  });

  final cameras = await availableCameras();
  runApp(MainApp(cameras: cameras));
}

class MainApp extends StatefulWidget {
  // Changé en StatefulWidget pour l'écouteur initial
  final List<CameraDescription> cameras;
  const MainApp({super.key, required this.cameras});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // --- AJOUT 4 : Lier la navigatorKey ---
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Agri Alert',
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      initialRoute: AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: (context) =>
            OnboardingScreen(finishRoute: AppRoutes.connecter),
        AppRoutes.connecter: (context) => LoginScreen(),
        AppRoutes.inscrire: (context) => SignupScreen(),
        AppRoutes.forgotPassword: (context) => ForgotPasswordScreen(),
        AppRoutes.newPassword: (context) => NewPasswordScreen(),
        AppRoutes.createChamp: (context) => CreateChampScreen(),
        AppRoutes.accueil: (context) => const HomeScreen(),
        AppRoutes.scan: (context) => ScannerPage(cameras: widget.cameras),
        AppRoutes.recommandation: (context) => const RecommandationsScreen(),
        AppRoutes.modifieProfil: (context) => const EditProfileScreen(),
        AppRoutes.modifieChamp: (context) => const ModifieChampPage(),
        AppRoutes.meteo: (context) => const WeatherPage(),
        AppRoutes.notifications: (context) => const NotificationScreen(),
      },
    );
  }
}
