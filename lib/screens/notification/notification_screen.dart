import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_images.dart';
import 'package:agri_alert/constants/app_text_styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const double _sidePadding = 18;
  static const double _headerHeight = 86;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gris2, 
      body: Column(
        children: [
          _Header(
            height: _headerHeight,
            sidePadding: _sidePadding, 
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                _sidePadding,
                16,
                _sidePadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SectionTitle('Nouveau'),
                  SizedBox(height: 10),
                  _NotificationGroupCard(
                    items: [
                      _NotificationItem(
                        icon: AppImages.inondation,
                        message:
                            "Risque d'inondation, pluies intenses attendues aujourd'hui.",
                      ),
                      _NotificationItem(
                        icon: AppImages.pluie,
                        message:
                            "Orage probable: sécurisez les équipements au champ.",
                      ),
                    ],
                  ),
                  SizedBox(height: 18),

                  _SectionTitle('Hier'),
                  SizedBox(height: 10),
                  _NotificationGroupCard(
                    items: [
                      _NotificationItem(
                        icon: AppImages.nuage,
                        message:
                            "Météo stable : conditions favorables aux travaux agricoles.",
                      ),
                      _NotificationItem(
                        icon: AppImages.secheresse,
                        message:
                            "Chaleur élevée, risque de stress hydrique pour les cultures.",
                      ),
                    ],
                  ),
                  SizedBox(height: 18),

                  _SectionTitle('Semaine passée'),
                  SizedBox(height: 10),
                  _NotificationGroupCard(
                    items: [
                      _NotificationItem(
                        icon: AppImages.inondation,
                        message:
                            "Risque d'inondation, pluies intenses attendues aujourd'hui.",
                      ),
                      _NotificationItem(
                        icon: AppImages.pluie,
                        message: "Pluie forte dans 2h: protégez les semis.",
                      ),
                    ],
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

/// --------------------------- HEADER (MODIFIÉ) ---------------------------
class _Header extends StatelessWidget {
  final double height, sidePadding;
  final VoidCallback onBack;

  const _Header({
    required this.height,
    required this.sidePadding,
    required this.onBack,
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
                  colors: [
                    AppColors.vert,
                    AppColors.vert.withOpacity(0.92),
                  ],
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
              topPaddingFromSystem + 14,
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
                      color: Colors.transparent,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------------- SECTION TITLE ---------------------------

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

/// ------------------------ NOTIFICATION GROUP CARD ------------------------

class _NotificationGroupCard extends StatelessWidget {
  final List<_NotificationItem> items;

  const _NotificationGroupCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 14),
            child: _NotificationRow(item: item),
          );
        }),
      ),
    );
  }
}

/// ----------------------------- SINGLE ROW -----------------------------

class _NotificationRow extends StatelessWidget {
  final _NotificationItem item;
  const _NotificationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _IconBubble(svgAsset: item.icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.message,
            style: AppTextStyles.textnoir.copyWith(
              fontSize: 14,
              height: 1.25,
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
  final String svgAsset;
  const _IconBubble({required this.svgAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.vert,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        svgAsset,
        width: 22,
        height: 22,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

/// ------------------------------ MODEL ------------------------------

class _NotificationItem {
  final String icon;
  final String message;

  const _NotificationItem({
    required this.icon,
    required this.message,
  });
}