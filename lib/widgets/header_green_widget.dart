import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class HeaderGreenWidget extends StatelessWidget {
  const HeaderGreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Fond vert
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: const BoxDecoration(
            color: AppColors.vert,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // 2. Motif feuille
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
      ],
    );
  }
}
