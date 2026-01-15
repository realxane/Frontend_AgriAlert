import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconsax/iconsax.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ✅ Limites d’affichage par défaut (preview)
  static const int _maxAlertsPreview = 2;
  static const int _maxDiagnosticsPreview = 6;

  // ✅ Toggle “Voir tout / Voir moins”
  bool _showAllAlerts = false; 
  bool _showAllDiagnostics = false;

  final List<_AlertItem> _alerts = const [
    _AlertItem(title: 'Forte sécheresse', date: 'Jeudi°17/12/2025'),
    _AlertItem(title: 'Forte sécheresse', date: 'Jeudi°17/12/2025'),
    _AlertItem(title: 'Inondation', date: 'Vendredi°18/12/2025'),
    _AlertItem(title: 'Vent fort', date: 'Samedi°19/12/2025'),
  ];

  final List<_DiagItem> _diagnostics = const [
    _DiagItem(label: 'Maïs', date: 'Jeudi°17/12/2025'),
    _DiagItem(label: 'Maïs', date: 'Jeudi°17/12/2025'),
    _DiagItem(label: 'Maïs', date: 'Jeudi°17/12/2025'),
    _DiagItem(label: 'Maïs', date: 'Jeudi°17/12/2025'),
    _DiagItem(label: 'Maïs', date: 'Jeudi°17/12/2025'),
    _DiagItem(label: 'Maïs', date: 'Jeudi°17/12/2025'),
    _DiagItem(label: 'Riz', date: 'Dimanche°20/12/2025'),
    _DiagItem(label: 'Tomate', date: 'Lundi°21/12/2025'),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    const fabSize = 66.0;
    const bottomBarBaseHeight = 64.0;
    final bottomInset = media.padding.bottom;
    final bottomBarTotalHeight = bottomBarBaseHeight + bottomInset;
    final scrollBottomPadding = bottomBarTotalHeight + (fabSize / 2) + 18;

    // ✅ Calculs “preview vs full”
    final hasMoreAlerts = _alerts.length > _maxAlertsPreview;
    final hasMoreDiagnostics = _diagnostics.length > _maxDiagnosticsPreview;

    final alertsToShow = (_showAllAlerts || !hasMoreAlerts)
        ? _alerts
        : _alerts.take(_maxAlertsPreview).toList();

    final diagnosticsToShow = (_showAllDiagnostics || !hasMoreDiagnostics)
        ? _diagnostics
        : _diagnostics.take(_maxDiagnosticsPreview).toList();

    return Scaffold(
      backgroundColor: AppColors.gris2,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _Header(
              userName: 'Alassane',
              subtitle: 'Commence tes activités agricoles',
              temperature: '29°',
              condition: 'Cloudy',
              topPadding: 18,
              sidePadding: 16,
              height: media.size.height * 0.2,
              onNotificationTap: () {},
              showNotificationDot: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 14, 16, scrollBottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- Alertes ----------------
                    _SectionHeader(
                      title: 'Alertes',
                      action: hasMoreAlerts
                          ? (_showAllAlerts ? 'Voir moins' : 'Voir tout')
                          : null,
                      onTap: hasMoreAlerts
                          ? () => setState(() => _showAllAlerts = !_showAllAlerts)
                          : null,
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
                            if (i != alertsToShow.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // -------- Historique de diagnostics --------
                    _SectionHeader(
                      title: 'Historique de diagnostics',
                      action: hasMoreDiagnostics
                          ? (_showAllDiagnostics ? 'Voir moins' : 'Voir tout')
                          : null,
                      onTap: hasMoreDiagnostics
                          ? () => setState(() =>
                              _showAllDiagnostics = !_showAllDiagnostics)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _CardContainer(
                      child: Column(
                        children: [
                          for (int i = 0; i < diagnosticsToShow.length; i++) ...[
                            _ListRow(
                              leadingImage: AppImages.alassane,
                              title: diagnosticsToShow[i].label,
                              subtitle: diagnosticsToShow[i].date,
                            ),
                            if (i != diagnosticsToShow.length - 1)
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: fabSize,
        height: fabSize,
        child: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.transparent,
          onPressed: () {},
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
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

/* ----------------------------- HEADER ----------------------------- */

class _Header extends StatelessWidget {
  final String userName;
  final String subtitle;
  final String temperature;
  final String condition;
  final double height;
  final double topPadding;
  final double sidePadding;
  final VoidCallback onNotificationTap;
  final bool showNotificationDot;

  const _Header({
    required this.userName,
    required this.subtitle,
    required this.temperature,
    required this.condition,
    required this.height,
    required this.topPadding,
    required this.sidePadding,
    required this.onNotificationTap,
    required this.showNotificationDot,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Container(
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
            padding:
                EdgeInsets.fromLTRB(sidePadding, topPadding, sidePadding, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(image: AppImages.alassane, size: 44),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour $userName !',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titre1.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.textgris.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _NotificationIconifyButton(
                      onTap: onNotificationTap,
                      showDot: showNotificationDot,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Image.asset(
                      AppImages.nuagemeteo,
                      height: 46,
                      fit: BoxFit.contain,
                    ),
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
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          temperature,
                          style: AppTextStyles.textnoir.copyWith(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
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
          border: Border.all(
            color: Colors.white.withOpacity(0.55),
            width: 1.2,
          ),
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

/* --------------------------- SECTIONS ---------------------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action; // ✅ optionnel
  final VoidCallback? onTap; // ✅ optionnel

  const _SectionHeader({
    required this.title,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showAction = action != null && onTap != null;

    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.textnoir.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (showAction)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                action!,
                style: AppTextStyles.textnoir.copyWith(
                  color: AppColors.vert,
                  fontWeight: FontWeight.w700,
                ),
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
  final String leadingImage;
  final String title;
  final String subtitle;

  const _ListRow({
    required this.leadingImage,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(image: leadingImage, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    AppTextStyles.textnoir.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.textgris2),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String image;
  final double size;

  const _Avatar({required this.image, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
    );
  }
}

/* ------------------------- BOTTOM BAR ---------------------------- */

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
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(width: 72),
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
  final String label;
  final String iconSelected;
  final String iconUnselected;
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(
                selected ? iconSelected : iconUnselected,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.textgris.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 10,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------- MODELS ------------------------------ */

class _AlertItem {
  final String title;
  final String date;
  const _AlertItem({required this.title, required this.date});
}

class _DiagItem {
  final String label;
  final String date;
  const _DiagItem({required this.label, required this.date});
}
