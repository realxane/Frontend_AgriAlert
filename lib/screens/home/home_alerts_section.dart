import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:agri_alert/models/notification_model.dart';
import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/config/app_config.dart';

class HomeAlertsSection extends StatefulWidget {
  final VoidCallback onSeeAll;

  const HomeAlertsSection({
    super.key,
    required this.onSeeAll,
    required List<NotificationModel> notifications,
  });

  @override
  State<HomeAlertsSection> createState() => _HomeAlertsSectionState();
}

class _HomeAlertsSectionState extends State<HomeAlertsSection> {
  final _storage = const FlutterSecureStorage();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _showAll = false;
  final List<String> _hiddenIds = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Récupération automatique au chargement
  }

  // --- FONCTION DE RÉCUPÉRATION DES DONNÉES DEPUIS LARAVEL ---
  Future<void> _fetchNotifications() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _notifications = data
                .map((json) => NotificationModel.fromJson(json))
                .toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erreur HomeAlerts: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIQUE DE FILTRAGE ET TRI ---
  List<NotificationModel> _getFilteredNotifications() {
    // 1. Filtrer les masquées
    final visible = _notifications
        .where((n) => !_hiddenIds.contains(n.id))
        .toList();

    // 2. Trier par date (plus récent en haut)
    visible.sort((a, b) => b.date.compareTo(a.date));

    // 3. Limiter à 3 si on n'a pas cliqué sur "Voir tout"
    if (_showAll) return visible;
    return visible.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppColors.vert),
        ),
      );
    }

    final alertsToShow = _getFilteredNotifications();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Alertes',
          action: _notifications.length > 3
              ? (_showAll ? 'Voir moins' : 'Voir tout')
              : null,
          onTap: () {
            setState(() => _showAll = !_showAll);
          },
        ),
        const SizedBox(height: 10),
        _CardContainer(
          child: alertsToShow.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      "Aucune alerte enregistrée.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(alertsToShow.length, (index) {
                    final item = alertsToShow[index];
                    return Dismissible(
                      key: Key('home_notif_${item.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.visibility_off_outlined,
                          color: Colors.orange,
                        ),
                      ),
                      onDismissed: (_) {
                        setState(() => _hiddenIds.add(item.id));
                      },
                      child: Column(
                        children: [
                          _ListRowNotification(item: item),
                          if (index != alertsToShow.length - 1)
                            Divider(
                              height: 24,
                              color: Colors.black.withOpacity(0.05),
                              indent: 54,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

/* ------------------------- COMPOSANTS UI INTERNES ---------------------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const _SectionHeader({required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.textnoir.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        if (action != null)
          InkWell(
            onTap: onTap,
            child: Text(
              action!,
              style: AppTextStyles.textnoir.copyWith(
                color: AppColors.vert,
                fontWeight: FontWeight.w700,
                fontSize: 14,
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ListRowNotification extends StatelessWidget {
  final NotificationModel item;
  const _ListRowNotification({required this.item});

  @override
  Widget build(BuildContext context) {
    final String dateFormatted =
        "${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}";

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.vert,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: item.icon.endsWith('.svg')
              ? SvgPicture.asset(
                  item.icon,
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (_) =>
                      const Icon(Icons.notifications, color: Colors.white),
                )
              : const Icon(Icons.notifications, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.message,
                style: AppTextStyles.textnoir.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                dateFormatted,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
