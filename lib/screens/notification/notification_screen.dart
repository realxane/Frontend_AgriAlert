import 'package:agri_alert/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/config/app_config.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  static const double _sidePadding = 18;
  static const double _headerHeight = 86;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // RÉCUPÉRATION DES NOTIFICATIONS
  Future<void> _fetchNotifications() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _notifications = data
              .map((n) => NotificationModel.fromJson(n))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // SUPPRESSION INDIVIDUELLE
  Future<void> _deleteNotification(String id) async {
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
        });
        _showSnackBar("Notification supprimée");
      }
    } catch (e) {
      debugPrint("Erreur suppression: $e");
    }
  }

  // SUPPRESSION GLOBALE (TOUT EFFACER)
  Future<void> _deleteAllNotifications() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications.clear();
        });
        _showSnackBar("Toutes les notifications ont été effacées");
      }
    } catch (e) {
      debugPrint("Erreur suppression globale: $e");
    }
  }

  // DIALOGUE DE CONFIRMATION
  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tout effacer ?"),
        content: const Text(
          "Voulez-vous vraiment supprimer toutes vos alertes ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllNotifications();
            },
            child: const Text(
              "Effacer tout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  List<NotificationModel> _filterByDate(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _notifications.where((n) {
      final notificationDate = DateTime(n.date.year, n.date.month, n.date.day);
      if (period == 'Nouveau') return notificationDate.isAtSameMomentAs(today);
      if (period == 'Hier') return notificationDate.isAtSameMomentAs(yesterday);
      return notificationDate.isBefore(yesterday);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final newNotifications = _filterByDate('Nouveau');
    final yesterdayNotifications = _filterByDate('Hier');
    final olderNotifications = _filterByDate('Ancien');

    return Scaffold(
      backgroundColor: AppColors.gris2,
      body: Column(
        children: [
          _Header(
            height: _headerHeight,
            sidePadding: _sidePadding,
            onBack: () => Navigator.pop(context),
            onDeleteAll: _notifications.isNotEmpty ? _confirmDeleteAll : null,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.vert),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchNotifications,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        _sidePadding,
                        16,
                        _sidePadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (newNotifications.isNotEmpty) ...[
                            const _SectionTitle('Nouveau'),
                            const SizedBox(height: 10),
                            _NotificationGroupCard(
                              items: newNotifications,
                              onDelete: (id) => _deleteNotification(id),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (yesterdayNotifications.isNotEmpty) ...[
                            const _SectionTitle('Hier'),
                            const SizedBox(height: 10),
                            _NotificationGroupCard(
                              items: yesterdayNotifications,
                              onDelete: (id) => _deleteNotification(id),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (olderNotifications.isNotEmpty) ...[
                            const _SectionTitle('Semaine passée'),
                            const SizedBox(height: 10),
                            _NotificationGroupCard(
                              items: olderNotifications,
                              onDelete: (id) => _deleteNotification(id),
                            ),
                          ],
                          if (_notifications.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: Text("Aucune alerte météo enregistrée."),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double height, sidePadding;
  final VoidCallback onBack;
  final VoidCallback? onDeleteAll;

  const _Header({
    required this.height,
    required this.sidePadding,
    required this.onBack,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: height + topPadding,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.vert, AppColors.vert.withOpacity(0.92)],
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
              opacity: 0.85,
              child: Image.asset(
                AppImages.feuille,
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              sidePadding,
              topPadding + 14,
              sidePadding,
              12,
            ),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gris1),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notifications',
                  style: AppTextStyles.titre1.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (onDeleteAll != null)
                  TextButton(
                    onPressed: onDeleteAll,
                    child: Text(
                      'Tout effacer',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.textnoir.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _NotificationGroupCard extends StatelessWidget {
  final List<NotificationModel> items;
  final Function(String) onDelete;

  const _NotificationGroupCard({required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.redAccent,
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            onDismissed: (direction) => onDelete(item.id),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: _NotificationRow(item: item),
                ),
                if (i != items.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.black.withOpacity(0.05),
                    indent: 14,
                    endIndent: 14,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final NotificationModel item;
  const _NotificationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBubble(iconAsset: item.icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.message,
            style: AppTextStyles.textnoir.copyWith(
              fontSize: 14,
              color: Colors.black.withOpacity(0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBubble extends StatelessWidget {
  final String iconAsset;
  const _IconBubble({required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.vert,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: iconAsset.endsWith('.svg')
          ? SvgPicture.asset(
              iconAsset,
              width: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            )
          : Image.asset(
              iconAsset,
              width: 20,
              color: Colors.white,
              errorBuilder: (context, error, stack) => const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 20,
              ),
            ),
    );
  }
}
