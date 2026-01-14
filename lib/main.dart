import 'package:agri_alert/routes/app_routes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agri Alert',
      initialRoute: AppRoutes.onboarding, 
      routes: {
        // Les routes seront définies ici plus tard
      },
    );
  }
}
