import 'package:flutter/material.dart';
import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/widgets/auth_text_field.dart';
import 'package:agri_alert/widgets/orange_button.dart';

//  Ajouts pour l'intégration backend
import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';
import 'package:agri_alert/routes/app_routes.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _tokenCtrl = TextEditingController();
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _loading = false;
  final _api = ApiClient(baseUrl: AppConfig.baseUrl);

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _pass1Ctrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(String email) async {
    final token = _tokenCtrl.text.trim();
    final p1 = _pass1Ctrl.text;
    final p2 = _pass2Ctrl.text;

    if (token.isEmpty || p1.isEmpty || p2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
     
      await _api.post(
        '/api/auth/reset-password',
        body: {
          'token': token,
          'email': email,
          'motdepasse': p1,
          'motdepasse_confirmation': p2,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe réinitialisé avec succès.")),
      );

      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.connecter, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Email reçu du screen précédent (ForgotPasswordScreen)
    final args = ModalRoute.of(context)?.settings.arguments;
    final email = (args is Map && args['email'] != null) ? args['email'].toString() : '';

    final size = MediaQuery.sizeOf(context);

    final double headerHeight = (size.height * 0.25).clamp(250.0, 340.0);

    final double greenY1 = headerHeight * 0.30;
    final double greenY2 = headerHeight * 0.10;

    final double gray1Height = headerHeight + headerHeight * 0.20;
    final double gray2Height = headerHeight + headerHeight * 0.40;

    final double contentTopPadding = headerHeight - greenY1 + 120;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.white)),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: gray2Height,
              child: ClipPath(
                clipper: _WaveClipper(
                  y1: headerHeight * 0.26,
                  y2: headerHeight * 0.08,
                ),
                child: Container(color: AppColors.gris2),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: gray1Height,
              child: ClipPath(
                clipper: _WaveClipper(
                  y1: headerHeight * 0.23,
                  y2: headerHeight * 0.075,
                ),
                child: Container(color: AppColors.gris1),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: headerHeight,
              child: ClipPath(
                clipper: _WaveClipper(y1: greenY1, y2: greenY2),
                child: Container(color: AppColors.vert),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Center(
                  child: Image.asset(
                    AppImages.logo,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
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
                  Center(
                    child: Text(
                      "Créez un nouveau\nmot de passe",
                      style: AppTextStyles.titre1,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ✅ Token (obligatoire côté backend)
                  Text('Token', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Collez le token reçu par email',
                    controller: _tokenCtrl,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 14),

                  Text('Mot de passe', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Entrez le nouveau mot de passe',
                    obscureText: true,
                    controller: _pass1Ctrl,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 14),

                  Text('Mot de passe', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Confirmez le nouveau mot de passe',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    controller: _pass2Ctrl,
                  ),

                  const SizedBox(height: 18),

                  OrangeButton(
                    label: _loading ? '...' : 'Enregistrer le mot de passe',
                    onPressed: _loading ? null : () => _resetPassword(email),
                  ),

                  const SizedBox(height: 26),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retour à la connexion',
                        style: AppTextStyles.textgris.copyWith(
                          color: AppColors.violet,
                        ),
                      ),
                    ),
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
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height - y1,
        size.width,
        size.height - y2,
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) {
    return oldClipper.y1 != y1 || oldClipper.y2 != y2;
  }
}
