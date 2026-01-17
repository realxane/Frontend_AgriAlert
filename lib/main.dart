import 'package:agri_alert/routes/app_routes.dart';
import 'package:agri_alert/screens/Recommandation/recommandation_page.dart';
import 'package:agri_alert/screens/auth/forgot_password_screen.dart';
import 'package:agri_alert/screens/auth/new_password_screen.dart';
import 'package:agri_alert/screens/meteo/meteo_page.dart';
import 'package:agri_alert/screens/profil/modifie_champ_page.dart';
import 'package:agri_alert/screens/profil/modifie_profil_page.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  runApp(MainApp(cameras: cameras));
}

class MainApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MainApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

        AppRoutes.scan: (context) => ScannerPage(cameras: cameras),
        AppRoutes.recommandation: (context) => const RecommandationsScreen(),
        AppRoutes.modifieProfil: (context) => const EditProfileScreen(),
        AppRoutes.modifieChamp: (context) => const ModifieChampPage(),
        AppRoutes.meteo: (context) => const WeatherPage(),
        AppRoutes.notifications: (context) => const NotificationScreen(),
      },
    );
  }
}
