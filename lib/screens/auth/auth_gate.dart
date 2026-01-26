// lib/screens/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agri_alert/routes/app_routes.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return _storage.read(key: 'access_token');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snap.data;
        if (token != null && token.isNotEmpty) {
          //  Déjà connecté
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.accueil,
              (_) => false,
            );
          });
        } else {
          //  Pas connecté
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.connecter,
              (_) => false,
            );
          });
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}
