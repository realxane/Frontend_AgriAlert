import 'dart:io';

import 'package:agri_alert/screens/home/home_alerts_section.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:agri_alert/screens/meteo/meteo_page.dart';
import 'package:agri_alert/screens/profil/profil_page.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_images.dart';
import 'package:agri_alert/routes/app_routes.dart';
import '../Recommandation/recommandation_page.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';

import 'package:agri_alert/services/weather_api.dart';
import 'package:agri_alert/services/diagnostic_api.dart';
import 'package:agri_alert/models/diagnostic_model.dart';
import 'package:agri_alert/models/notification_model.dart';

import 'package:agri_alert/screens/IA/diagnostic_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// ---------------------------------------------------------------------------
/// HELPERS (format maladie + normalisation URL image)
/// ---------------------------------------------------------------------------

/// Map des plantes vers FR
const Map<String, String> _plantFR = {
  'papaye': 'Papaye',
  'mango': 'Mangue',
  'citrus': 'Agrumes',
  'orange': 'Orange',
  'tomato': 'Tomate',
  'maize': 'Maïs',
  'potato': 'Pomme de terre',
  'grape': 'Raisin',
  'strawberry': 'Fraise',
};

/// Map des maladies vers FR (tu peux compléter selon tes classes)
const Map<String, String> _diseaseFR = {
  'healthy': 'Sain',
  'mosaic': 'Mosaïque',
  'citrus canker': 'Chancre des agrumes',
  'sooty mould': 'Fumagine (moisissure noire)',
  'anthracnose': 'Anthracnose',
  'powdery mildew': 'Oïdium',
  'leaf spot': 'Taches foliaires',
  'black rot': 'Pourriture noire',
};

String formatMaladieFr(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return 'Diagnostic';

  // normalise séparateurs
  s = s.replaceAll('-', '_');
  s = s.replaceAll(RegExp(r'\s+'), '_'); // espaces -> _
  final parts = s.split('_').where((e) => e.trim().isNotEmpty).toList();

  // si format inattendu, juste remplace "_" par " "
  if (parts.length < 2) {
    return raw.replaceAll('_', ' ').trim();
  }

  final plantKey = parts.first.toLowerCase();
  final plant = _plantFR[plantKey] ?? _capitalize(parts.first);

  final diseaseRaw = parts.sublist(1).join(' ').toLowerCase();

  // certains modèles ont "Sooty Mould" avec espace => on gère déjà
  final disease = _diseaseFR[diseaseRaw] ?? _capitalizeWords(diseaseRaw);

  if (disease.toLowerCase() == 'sain' || disease.toLowerCase() == 'healthy') {
    return '$plant (Sain)';
  }

  // rendu lisible
  // ex: "Mosaïque de la Papaye"
  if (disease.toLowerCase().contains('chancre')) {
    return disease; // déjà explicite
  }
  if (disease.toLowerCase().contains('fumagine')) {
    return '$disease ($plant)';
  }

  return '$disease de $plant';
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

String _capitalizeWords(String s) => s
    .split(' ')
    .where((w) => w.isNotEmpty)
    .map(_capitalize)
    .join(' ')
    .trim();

/// Convertit une URL stockée en DB en URL accessible (vrai téléphone OK)
/// - Si DB contient localhost ou 10.0.2.2 -> on remplace par AppConfig.baseUrl
/// - Si DB contient un chemin relatif -> on le combine avec AppConfig.baseUrl
String resolveDiagnosticImageUrl(String img) {
  if (img.trim().isEmpty) return '';

  final base = Uri.parse(AppConfig.baseUrl);

  bool isPrivateHost(String host) {
    if (host == 'localhost' || host == '10.0.2.2') return true;

    // 192.168.x.x
    if (host.startsWith('192.168.')) return true;

    // 10.x.x.x
    if (host.startsWith('10.')) return true;

    // 172.16.x.x -> 172.31.x.x
    if (host.startsWith('172.')) {
      final parts = host.split('.');
      if (parts.length >= 2) {
        final second = int.tryParse(parts[1]) ?? -1;
        if (second >= 16 && second <= 31) return true;
      }
    }
    return false;
  }

  // cas absolu
  if (img.startsWith('http://') || img.startsWith('https://')) {
    final u = Uri.parse(img);

    // si host local/privé -> on remplace par baseUrl
    if (isPrivateHost(u.host)) {
      final fixed = u.replace(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : u.port,
      );
      return fixed.toString();
    } 

    return img; // URL publique OK
  }

  // cas relatif
  final cleaned = img.startsWith('/') ? img.substring(1) : img;
  return base.resolve('/$cleaned').toString();
}


class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _api = ApiClient(baseUrl: AppConfig.baseUrl);
  static const _storage = FlutterSecureStorage();

  final WeatherApi _weatherApi = WeatherApi();
  final DiagnosticApi _diagApi = DiagnosticApi();

  String _userName = "Utilisateur";
  String? _userPhotoUrl;
  String? _champId;
  String _temp = '--°';
  String _condition = '--';

  List<DiagnosticResult> _diagnostics = [];
  List<NotificationModel> _notifications = []; // Liste pour les alertes
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() => _isLoading = true);

      final token = await _storage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 1) Profil
      final profileRes = await _api.get(
        '/api/profile/me',
        headers: {'Authorization': 'Bearer $token'},
      );

      final userJson =
          (profileRes['user'] as Map?)?.cast<String, dynamic>() ?? {};
      final userName = (userJson['nom'] ?? "Utilisateur").toString();
      final photoUrl = userJson['photo_url']?.toString();

      // 2) Champs
      final champsRes = await _api.get(
        '/api/champs',
        headers: {'Authorization': 'Bearer $token'},
      );
      final champsList = (champsRes['champs'] as List?)?.cast<dynamic>() ?? [];
      final champId =
          champsList.isNotEmpty ? (champsList[0]['id'] ?? '').toString() : null;

      // 3) Météo
      String temp = '--°';
      String condition = '--';
      if (champId != null && champId.isNotEmpty) {
        try {
          final todayRes = await _weatherApi.today(champId: champId);
          final today =
              (todayRes['today'] as Map?)?.cast<String, dynamic>() ?? {};
          final t =
              (today['temp'] is num) ? (today['temp'] as num).round() : null;
          final desc = today['desc']?.toString();
          if (t != null) temp = '$t°';
          if (desc != null && desc.isNotEmpty) {
            condition = _normalizeWeather(desc);
          }
        } catch (_) {}
      }

      // 4) Diagnostics
      List<DiagnosticResult> diags = [];
      try {
        final diagRes = await _diagApi.getHistory(limit: 6);
        final list = (diagRes['diagnostics'] as List?)?.cast<dynamic>() ?? [];
        diags = list
            .map((e) =>
                DiagnosticResult.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      } catch (_) {}

      // 5) Notifications (Alertes)
      List<NotificationModel> notifs = [];
      try {
        final notifRes = await _api.get(
          '/api/notifications',
          headers: {'Authorization': 'Bearer $token'},
        );
        final list =
            (notifRes['notifications'] as List?)?.cast<dynamic>() ?? [];
        notifs = list
            .map((e) =>
                NotificationModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _userName = userName;
        _userPhotoUrl = photoUrl;
        _champId = champId;
        _temp = temp;
        _condition = condition;
        _diagnostics = diags;
        _notifications = notifs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement home : $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _normalizeWeather(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('cloud')) return 'Cloudy';
    if (d.contains('clear') || d.contains('soleil') || d.contains('sun')) {
      return 'Sunny';
    }
    if (d.contains('rain') || d.contains('pluie')) return 'Rainy';
    if (d.contains('storm') || d.contains('orage')) return 'Storm';
    return desc;
  }

  /// Télécharge l'image pour DiagnosticPage (car DiagnosticPage attend un path local)
  Future<String> _downloadToLocalFile(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception("Téléchargement image échoué (${res.statusCode}).");
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/diag_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }

  /// Ouvre DiagnosticPage quand on clique sur un historique
  Future<void> _openDiagnostic(DiagnosticResult diag) async {
    try {
      final raw = diag.imageUrl.trim();
      if (raw.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune image disponible pour ce diagnostic.")),
        );
        return;
      }

      //  normalise URL (important sur téléphone)
      final url = resolveDiagnosticImageUrl(raw);

      // petit loader visible (sinon sur téléphone tu penses que rien ne se passe)
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final localPath = await _downloadToLocalFile(url);

      if (!mounted) return;
      Navigator.pop(context); // ferme le loader

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosticPage(imagePath: localPath),
        ),
      );
    } catch (e) {
      //  sur téléphone, on affiche l'erreur (sinon tu vois rien)
      if (!mounted) return;
      Navigator.pop(context); // ferme le loader si ouvert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir le diagnostic: $e")),
      );
      debugPrint("Erreur ouverture diag: $e");
    }
  }

  List<Widget> get _pages {
    return [
      _HomeContent(
        userName: _userName,
        userPhotoUrl: _userPhotoUrl,
        temperature: _temp,
        condition: _condition,
        diagnostics: _diagnostics,
        notifications: _notifications,
        onDiagnosticTap: _openDiagnostic,
      ),
      const RecommandationsScreen(),
      (_champId != null && _champId!.isNotEmpty)
          ? WeatherPage(champId: _champId!)
          : const Center(child: Text("Aucun champ disponible.")),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gris2,
      extendBody: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 66,
        height: 66,
        child: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.transparent,
          onPressed: () => Navigator.pushNamed(context, '/scan'),
          child: Image.asset(AppImages.scan, fit: BoxFit.contain),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        height: 64,
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) _loadHomeData();
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String userName;
  final String? userPhotoUrl;
  final String temperature;
  final String condition;
  final List<DiagnosticResult> diagnostics;
  final List<NotificationModel> notifications;
  final Future<void> Function(DiagnosticResult diag) onDiagnosticTap;

  const _HomeContent({
    required this.userName,
    this.userPhotoUrl,
    required this.temperature,
    required this.condition,
    required this.diagnostics,
    required this.notifications,
    required this.onDiagnosticTap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scrollBottomPadding = 64 + media.padding.bottom + (66 / 2) + 18;

    return Column(
      children: [
        _Header(
          userName: userName,
          userPhotoUrl: userPhotoUrl,
          subtitle: 'Commence tes activités agricoles',
          temperature: temperature,
          condition: condition,
          sidePadding: 16,
          height: media.size.height * 0.2,
          onNotificationTap: () =>
              Navigator.pushNamed(context, AppRoutes.notifications),
          showNotificationDot: true,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 14, 16, scrollBottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // composant alertes
                HomeAlertsSection(
                  notifications: notifications,
                  onSeeAll: () =>
                      Navigator.pushNamed(context, AppRoutes.notifications),
                ),

                const SizedBox(height: 18),

                _SectionHeader(
                  title: 'Historique de diagnostics',
                  action: diagnostics.length > 6 ? 'Voir tout' : null,
                  onTap: () {},
                ),
                const SizedBox(height: 10),

                _CardContainer(
                  child: diagnostics.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Aucun diagnostic."),
                        )
                      : Column(
                          children: [
                            for (int i = 0;
                                i < (diagnostics.length > 6 ? 6 : diagnostics.length);
                                i++) ...[
                              //  InkWell fiable + zone cliquable pleine largeur
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => onDiagnosticTap(diagnostics[i]),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: _ListRow(
                                      //  photo diagnostic (réelle)
                                      leadingUrl: resolveDiagnosticImageUrl(diagnostics[i].imageUrl),
                                      leadingFallbackAsset: AppImages.alassane,

                                      //  nom FR lisible
                                      title: formatMaladieFr(diagnostics[i].maladie),

                                      subtitle: diagnostics[i].createdAtShort,
                                    ),
                                  ),
                                ),
                              ),
                              if (i != (diagnostics.length > 6 ? 5 : diagnostics.length - 1))
                                const SizedBox(height: 12),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ----------------------------- LES AUTRES WIDGETS INTERNES RESTENT INCHANGÉS ----------------------------- */

class _Header extends StatelessWidget {
  final String userName, subtitle, temperature, condition;
  final String? userPhotoUrl;
  final double height, sidePadding;
  final VoidCallback onNotificationTap;
  final bool showNotificationDot;

  const _Header({
    required this.userName,
    this.userPhotoUrl,
    required this.subtitle,
    required this.temperature,
    required this.condition,
    required this.height,
    required this.sidePadding,
    required this.onNotificationTap,
    required this.showNotificationDot,
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: height + topPadding,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                  colors: [AppColors.vert, AppColors.bleu],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -10,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(AppImages.feuille, height: 100),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              sidePadding,
              topPadding + 12,
              sidePadding,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(
                      imagePath: AppImages.alassane,
                      networkUrl: userPhotoUrl,
                      size: 44,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour $userName !',
                            style: AppTextStyles.titre1.copyWith(
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: AppTextStyles.textgris.copyWith(
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _NotificationIconifyButton(
                      onTap: onNotificationTap,
                      showDot: showNotificationDot,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Image.asset(AppImages.nuagemeteo, height: 46),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Today',
                          style: AppTextStyles.titre1.copyWith(
                            color: AppColors.orange,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          temperature,
                          style: AppTextStyles.textnoir.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          condition,
                          style: AppTextStyles.textgris.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationIconifyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool showDot;
  const _NotificationIconifyButton({
    required this.onTap,
    required this.showDot,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.vert.withOpacity(0.90),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.2),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Iconsax.notification,
                size: 20,
                color: Colors.black.withOpacity(0.95),
              ),
            ),
            if (showDot)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const _SectionHeader({required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.textnoir.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        if (action != null)
          InkWell(
            onTap: onTap,
            child: Text(
              action!,
              style: AppTextStyles.textnoir.copyWith(
                color: AppColors.vert,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ListRow extends StatelessWidget {
  final String title;
  final String subtitle;

  //  avatar dynamique
  final String? leadingUrl;
  final String leadingFallbackAsset;

  const _ListRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingUrl,
    required this.leadingFallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NetworkOrAssetAvatar(
          url: leadingUrl,
          fallbackAsset: leadingFallbackAsset,
          size: 40,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.textnoir.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.textgris2.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NetworkOrAssetAvatar extends StatelessWidget {
  final String? url;
  final String fallbackAsset;
  final double size;

  const _NetworkOrAssetAvatar({
    required this.url,
    required this.fallbackAsset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = (url != null && url!.trim().isNotEmpty);

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: hasUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  fallbackAsset,
                  fit: BoxFit.cover,
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                (progress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    ),
                  );
                },
              )
            : Image.asset(
                fallbackAsset,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imagePath;
  final String? networkUrl;
  final double size;
  const _Avatar({required this.imagePath, this.networkUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: (networkUrl != null && networkUrl!.isNotEmpty)
              ? NetworkImage(networkUrl!) as ImageProvider
              : AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double height;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomBar({
    required this.height,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      height: height,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              label: 'Home',
              iconSelected: Ph.house_fill,
              iconUnselected: Ph.house_light,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              label: 'Recommandation',
              iconSelected: Ph.lightbulb_filament_fill,
              iconUnselected: Ph.lightbulb_filament_light,
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: _NavItem(
              label: 'Météo',
              iconSelected: Ph.cloud_sun_fill,
              iconUnselected: Ph.cloud_sun_light,
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _NavItem(
              label: 'Profil',
              iconSelected: Ph.user_circle_fill,
              iconUnselected: Ph.user_circle_light,
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label, iconSelected, iconUnselected;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.label,
    required this.iconSelected,
    required this.iconUnselected,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.vert : AppColors.gris3;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            selected ? iconSelected : iconUnselected,
            size: 22,
            color: color,
          ),
          Text(
            label,
            style: AppTextStyles.textgris.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
