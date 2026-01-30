import 'dart:io';
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

// page diagnostic IA
import 'package:agri_alert/screens/IA/diagnostic_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _api = ApiClient(baseUrl: AppConfig.baseUrl);
  static const _storage = FlutterSecureStorage();

  final WeatherApi _weatherApi = WeatherApi();
  final DiagnosticApi _diagApi = DiagnosticApi();

  // Infos Utilisateur
  String _userName = "Utilisateur";
  String? _userPhotoUrl;

  // ChampId (important pour météo)
  String? _champId;

  //  Météo (header)
  String _temp = '--°';
  String _condition = '--';

  //  Diagnostics (liste)
  List<DiagnosticResult> _diagnostics = [];

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

      // 2) ChampId de l'utilisateur (on prend le 1er champ)
      final champsRes = await _api.get(
        '/api/champs',
        headers: {'Authorization': 'Bearer $token'},
      );
      final champsList = (champsRes['champs'] as List?)?.cast<dynamic>() ?? [];
      final champId = champsList.isNotEmpty
          ? (champsList[0]['id'] ?? '').toString()
          : null;

      // 3) Météo today pour ce champ
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
        } catch (_) {
          // si météo échoue, on garde "--"
        }
      }

      // 4) Historique diagnostics (preview)
      List<DiagnosticResult> diags = [];
      try {
        final diagRes = await _diagApi.getHistory(limit: 6);
        final list = (diagRes['diagnostics'] as List?)?.cast<dynamic>() ?? [];
        diags = list
            .map((e) =>
                DiagnosticResult.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      } catch (_) {
        // si diagnostics échoue, on garde liste vide
      }

      if (!mounted) return;

      setState(() {
        _userName = userName;
        _userPhotoUrl = photoUrl;
        _champId = champId;

        _temp = temp;
        _condition = condition;

        _diagnostics = diags;

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

  //  Télécharge l'image_url en fichier local pour DiagnosticPage (qui attend un path local)
  Future<String> _downloadToLocalFile(String url) async {
    final uri = Uri.parse(url);
    final res = await http.get(uri);
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

  //  Ouvrir DiagnosticPage quand on clique sur un historique
  Future<void> _openDiagnostic(DiagnosticResult diag) async {
    try {
      // Ton modèle a imageUrl = json['image_url']
      final img = diag.imageUrl;

      if (img.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune image disponible pour ce diagnostic.")),
        );
        return;
      }

      String localPath;

      // Si c'est déjà un fichier local
      if (img.startsWith('/') || img.startsWith('file://')) {
        localPath = img.replaceFirst('file://', '');
      } else if (img.startsWith('http://') || img.startsWith('https://')) {
        //  convertir URL -> fichier local
        localPath = await _downloadToLocalFile(img);
      } else {
        // cas relatif : ex "storage/diagnostics/xxx.jpg"
        final fullUrl = '${AppConfig.baseUrl}/$img'.replaceAll('//', '/').replaceFirst(':/', '://');
        localPath = await _downloadToLocalFile(fullUrl);
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosticPage(imagePath: localPath),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir ce diagnostic: $e")),
      );
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
        onDiagnosticTap: _openDiagnostic, // ✅ callback ici
      ),
      const RecommandationsScreen(),

      //  Important : on passe le vrai champId
      (_champId != null && _champId!.isNotEmpty)
          ? WeatherPage(champId: _champId!)
          : const Center(child: Text("Aucun champ disponible pour la météo.")),

      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const fabSize = 66.0;
    const bottomBarBaseHeight = 64.0;

    return Scaffold(
      backgroundColor: AppColors.gris2,
      extendBody: true,
      resizeToAvoidBottomInset: false,

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: fabSize,
        height: fabSize,
        child: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.transparent,
          onPressed: () {
            Navigator.pushNamed(context, '/scan');
          },
          child: Image.asset(
            AppImages.scan,
            width: fabSize,
            height: fabSize,
            fit: BoxFit.contain,
          ),
        ),
      ),

      bottomNavigationBar: _BottomBar(
        height: bottomBarBaseHeight,
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) _loadHomeData(); // Rafraîchir si on revient à l'accueil
        },
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* CONTENU DE L'ACCUEIL                                            */
/* -------------------------------------------------------------------------- */

class _HomeContent extends StatefulWidget {
  final String userName;
  final String? userPhotoUrl;

  // ✅ météo dynamique
  final String temperature;
  final String condition;

  // ✅ diagnostics dynamiques
  final List<DiagnosticResult> diagnostics;

  // ✅ callback au clic
  final Future<void> Function(DiagnosticResult diag) onDiagnosticTap;

  const _HomeContent({
    required this.userName,
    this.userPhotoUrl,
    required this.temperature,
    required this.condition,
    required this.diagnostics,
    required this.onDiagnosticTap,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  static const int _maxAlertsPreview = 2;
  static const int _maxDiagnosticsPreview = 6;

  bool _showAllAlerts = false;
  bool _showAllDiagnostics = false;

  final List<_AlertItem> _alerts = const [
    _AlertItem(title: 'Forte sécheresse', date: '17/12/2025'),
    _AlertItem(title: 'Forte sécheresse', date: '17/12/2025'),
    _AlertItem(title: 'Inondation', date: '18/12/2025'),
    _AlertItem(title: 'Vent fort', date: '19/12/2025'),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    const fabSize = 66.0;
    const bottomBarBaseHeight = 64.0;
    final bottomInset = media.padding.bottom;
    final bottomBarTotalHeight = bottomBarBaseHeight + bottomInset;
    final scrollBottomPadding = bottomBarTotalHeight + (fabSize / 2) + 18;

    final hasMoreAlerts = _alerts.length > _maxAlertsPreview;
    final alertsToShow =
        (_showAllAlerts || !hasMoreAlerts) ? _alerts : _alerts.take(_maxAlertsPreview).toList();

    final diags = widget.diagnostics;
    final hasMoreDiagnostics = diags.length > _maxDiagnosticsPreview;
    final diagnosticsToShow = (_showAllDiagnostics || !hasMoreDiagnostics)
        ? diags
        : diags.take(_maxDiagnosticsPreview).toList();

    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          _Header(
            userName: widget.userName,
            userPhotoUrl: widget.userPhotoUrl,
            subtitle: 'Commence tes activités agricoles',
            temperature: widget.temperature,
            condition: widget.condition,
            sidePadding: 16,
            height: media.size.height * 0.2,
            onNotificationTap: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
            showNotificationDot: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 14, 16, scrollBottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Alertes',
                    action: hasMoreAlerts ? (_showAllAlerts ? 'Voir moins' : 'Voir tout') : null,
                    onTap: hasMoreAlerts ? () => setState(() => _showAllAlerts = !_showAllAlerts) : null,
                  ),
                  const SizedBox(height: 10),
                  _CardContainer(
                    child: Column(
                      children: [
                        for (int i = 0; i < alertsToShow.length; i++) ...[
                          _ListRow(
                            leadingImage: AppImages.alassane,
                            title: alertsToShow[i].title,
                            subtitle: alertsToShow[i].date,
                          ),
                          if (i != alertsToShow.length - 1) const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  _SectionHeader(
                    title: 'Historique de diagnostics',
                    action: (hasMoreDiagnostics) ? (_showAllDiagnostics ? 'Voir moins' : 'Voir tout') : null,
                    onTap: (hasMoreDiagnostics) ? () => setState(() => _showAllDiagnostics = !_showAllDiagnostics) : null,
                  ),
                  const SizedBox(height: 10),

                  _CardContainer(
                    child: (diagnosticsToShow.isEmpty)
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Aucun diagnostic pour le moment."),
                          )
                        : Column(
                            children: [
                              for (int i = 0; i < diagnosticsToShow.length; i++) ...[
                                InkWell(
                                  // ✅ clic sur l’item -> ouvre DiagnosticPage
                                  onTap: () => widget.onDiagnosticTap(diagnosticsToShow[i]),
                                  child: _ListRow(
                                    leadingImage: AppImages.alassane,
                                    title: diagnosticsToShow[i].maladie,
                                    subtitle: diagnosticsToShow[i].createdAtShort,
                                  ),
                                ),
                                if (i != diagnosticsToShow.length - 1) const SizedBox(height: 12),
                              ],
                            ],
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

/* ----------------------------- HEADER ----------------------------- */

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
    final double topPaddingFromSystem = MediaQuery.of(context).padding.top;
    final double totalHeight = height + topPaddingFromSystem;

    return SizedBox(
      height: totalHeight,
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
              child: Image.asset(
                AppImages.feuille,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              sidePadding,
              topPaddingFromSystem + 12,
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
                            style: AppTextStyles.titre1.copyWith(color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: AppTextStyles.textgris.copyWith(color: Colors.black54),
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

/* --------------------------- COMPOSANTS ---------------------------- */

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
  final String leadingImage, title, subtitle;
  const _ListRow({
    required this.leadingImage,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(imagePath: leadingImage, size: 40),
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

/* ------------------------- BARRE DE NAVIGATION ---------------------------- */

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

class _AlertItem {
  final String title, date;
  const _AlertItem({required this.title, required this.date});
}
