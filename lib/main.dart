import 'package:agri_alert/routes/app_routes.dart';
import 'package:agri_alert/screens/auth/forgot_password_screen.dart';
import 'package:agri_alert/screens/auth/new_password_screen.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/champ_create_screen.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agri Alert',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: AppRoutes.onboarding, 
      routes: {
        // Les routes seront définies ici plus tard
        AppRoutes.onboarding: (context) => OnboardingScreen(finishRoute: AppRoutes.connecter),
        AppRoutes.connecter: (context) => LoginScreen(),
        AppRoutes.inscrire: (context) => SignupScreen(),
        AppRoutes.forgotPassword: (context) => ForgotPasswordScreen(),
        AppRoutes.newPassword: (context) => NewPasswordScreen(),
        AppRoutes.createChamp: (context) => CreateChampScreen(),
      },
    );
  }
}
