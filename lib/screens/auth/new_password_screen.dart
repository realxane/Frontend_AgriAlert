import 'package:flutter/material.dart';
import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/widgets/auth_text_field.dart';
import 'package:agri_alert/widgets/orange_button.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

                  Text('Mot de passe', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  const AuthTextField(
                    hintText: 'Entrez le nouveau mot de passe',
                    obscureText: true,
                  ),

                  const SizedBox(height: 14),

                  Text('Mot de passe', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  const AuthTextField(
                    hintText: 'Confirmez le nouveau mot de passe',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 18),

                  OrangeButton(
                    label: 'Enregistrer le mot de passe',
                    onPressed: () {
                      // TODO: envoyer le mail (Firebase/Auth/etc.)
                    },
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