import 'package:agri_alert/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/widgets/auth_text_field.dart';
import 'package:agri_alert/widgets/orange_button.dart';

//  Ajouts pour l'intégration backend
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';

//  Ajout Google Sign-In
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget { 
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //  Controllers pour lire les champs
  final _loginCtrl = TextEditingController(); // email OU téléphone
  final _passCtrl = TextEditingController();

  bool _loading = false;

  final _api = ApiClient(baseUrl: AppConfig.baseUrl);
  static const _storage = FlutterSecureStorage();

  //  Google sign in
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );


  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final login = _loginCtrl.text.trim();
    final pass = _passCtrl.text;

    if (login.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await _api.post(
        '/api/auth/login',
        body: {
          'login': login, // email OU téléphone
          'motdepasse': pass,
        },
      );

      final token = res['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception("access_token manquant dans la réponse.");
      }

      //  Sauvegarde token pour les routes protégées auth:sanctum
      await _storage.write(key: 'access_token', value: token);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.accueil, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur connexion: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  //  Connexion Google -> backend
  //  Connexion Google -> backend
Future<void> _doGoogleLogin() async {
  if (_loading) return;
  setState(() => _loading = true);

  try {
    // 1) Ouvrir la fenêtre Google (flow classique)
    await _googleSignIn.signOut();
    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // L’utilisateur a annulé
      return;
    }

    // 2) Obtenir les tokens Google
    final auth = await googleUser.authentication;

    // IMPORTANT : ton backend Socialite attend "access_token"
    final googleAccessToken = auth.accessToken;

    if (googleAccessToken == null || googleAccessToken.isEmpty) {
      throw Exception(
        "Google n'a pas retourné d'accessToken. Vérifie SHA-1 + package name + configuration OAuth Android.",
      );
    }

    // 3) Envoyer l'access token Google à Laravel
    final res = await _api.post(
      '/api/auth/google/callback',
      body: {
        'access_token': googleAccessToken,
      },
    );

    final token = res['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception("access_token Sanctum manquant dans la réponse.");
    }

    // 4) Sauvegarder le token Sanctum
    await _storage.write(key: 'access_token', value: token);

    if (!mounted) return;

    // 5) Aller à l'accueil
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.accueil, (_) => false);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur Google: $e")),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Un header responsive (évite que ça casse sur petits écrans)
    final double headerHeight = (size.height * 0.25).clamp(250.0, 340.0);

    // Réglages des courbes (tu peux ajuster finement si besoin)
    final double greenY1 = headerHeight * 0.30; // profondeur au centre
    final double greenY2 = headerHeight * 0.10; // hauteur aux bords

    final double gray1Height = headerHeight + headerHeight * 0.20;
    final double gray2Height = headerHeight + headerHeight * 0.40;

    // On démarre le contenu sous la zone des vagues
    final double contentTopPadding = headerHeight - greenY1 + 120;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond blanc
          const Positioned.fill(child: ColoredBox(color: Colors.white)),

          // --- Vagues (derrière le vert) ---
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

          // --- Vague verte (au-dessus) ---
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

          // --- Logo centré dans le vert ---
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

          // --- Contenu (formulaire) ---
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22, contentTopPadding, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titre
                  Center(
                    child: Text(
                      'Bienvenue à nouveau',
                      style: AppTextStyles.titre1,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Label Email
                  Text('Email', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),

                  // Backend attend "login" = email OU téléphone
                  AuthTextField(
                    hintText: 'Entrez votre email ou téléphone',
                    controller: _loginCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

                  // Label Mot de passe
                  Text('Mot de passe', style: AppTextStyles.textnoir),
                  const SizedBox(height: 8),
                  AuthTextField(
                    hintText: 'Entrez votre mot de passe',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    controller: _passCtrl,
                  ),

                  const SizedBox(height: 8),

                  // Mot de passe oublié ? (droite, violet)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        );
                      },
                      child: Text(
                        'mot de passe oublié ?',
                        style: AppTextStyles.textgris.copyWith(
                          color: AppColors.violet,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Bouton
                  OrangeButton(
                    label: _loading ? '...' : 'Se connecter',
                    onPressed: _loading ? null : _doLogin, //  login
                  ),

                  const SizedBox(height: 18),

                  // "ou" avec traits
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppColors.gris1),
                      ),
                      const SizedBox(width: 12),
                      Text('ou'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(height: 1, color: AppColors.gris1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Icônes sociales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialIcon(asset: AppImages.google, onTap: _doGoogleLogin),
                      const SizedBox(width: 26),
                      _SocialIcon(asset: AppImages.facebook, onTap: () {}),
                      const SizedBox(width: 26),
                      _SocialIcon(asset: AppImages.apple, onTap: () {}),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Bottom text
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.textnoir,
                        children: [
                          const TextSpan(text: "Vous n'avez pas de compte ? "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.inscrire);
                              },
                              child: Text(
                                "S'inscrire",
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
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Image.asset(
        asset,
        height: 30,
        width: 30,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Clip “vague” (simple et propre)
class _WaveClipper extends CustomClipper<Path> {
  final double y1; // profondeur au centre
  final double y2; // hauteur aux bords

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
