import 'package:agri_alert/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/widgets/auth_text_field.dart';
import 'package:agri_alert/widgets/orange_button.dart';

import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();

  final _telCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nom = _nomCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final pass2 = _passConfirmCtrl.text;
    final tel = _telCtrl.text.trim();

    if (nom.isEmpty || email.isEmpty || pass.isEmpty || tel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    if (pass != pass2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final api = ApiClient(baseUrl: AppConfig.baseUrl);

      final res = await api.post(
        '/api/auth/register/agriculteur/step1',
        body: {
          'nom': nom,
          'telephone': tel,
          'email': email,
          'motdepasse': pass,
          'motdepasse_confirmation': pass2,
        },
      );

      final sessionId = res['registration_session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception("registration_session_id manquant.");
      }

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.createChamp,
        arguments: sessionId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur inscription: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final double headerHeight = (size.height * 0.25).clamp(250.0, 340.0);
    final double greenY1 = headerHeight * 0.30;
    final double greenY2 = headerHeight * 0.10;
    final double gray1Height = headerHeight + headerHeight * 0.20;
    final double gray2Height = headerHeight + headerHeight * 0.40;
    final double contentTopPadding = headerHeight - greenY1 + 95;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.white)),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: gray2Height,
              child: ClipPath(
                clipper: _WaveClipper(y1: headerHeight * 0.26, y2: headerHeight * 0.08),
                child: Container(color: AppColors.gris2),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: gray1Height,
              child: ClipPath(
                clipper: _WaveClipper(y1: headerHeight * 0.23, y2: headerHeight * 0.075),
                child: Container(color: AppColors.gris1),
              ),
            ),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: headerHeight,
              child: ClipPath(
                clipper: _WaveClipper(y1: greenY1, y2: greenY2),
                child: Container(color: AppColors.vert),
              ),
            ),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Center(
                  child: Image.asset(AppImages.logo, height: 120, fit: BoxFit.contain),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22, contentTopPadding, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Text('Bienvenue', style: AppTextStyles.titre1)),

                  const SizedBox(height: 18),

                  Text('Nom', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(hintText: 'Entrez votre nom', controller: _nomCtrl),

                  const SizedBox(height: 12),

                  Text('Email', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Entrez votre email',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailCtrl,
                  ),

                  const SizedBox(height: 12),

                  Text('Mot de passe', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Entrez votre mot de passe',
                    obscureText: true,
                    controller: _passCtrl,
                  ),

                  const SizedBox(height: 12),

                  Text('Confirmer le mot de passe', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Confirmez votre mot de passe',
                    obscureText: true,
                    controller: _passConfirmCtrl,
                  ),

                  const SizedBox(height: 12),

                  Text('Téléphone', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Entrez votre numéro de téléphone',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    controller: _telCtrl,
                  ),

                  const SizedBox(height: 18),

                  OrangeButton(
                    label: _loading ? "..." : "S'inscrire",
                    onPressed: _loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double y1;
  final double y2;

  _WaveClipper({required this.y1, required this.y2});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - y2)
      ..quadraticBezierTo(size.width * 0.50, size.height - y1, size.width, size.height - y2)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) => oldClipper.y1 != y1 || oldClipper.y2 != y2;
}
