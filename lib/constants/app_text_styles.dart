import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Titres
  static const TextStyle titre1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Texte gris
  static const TextStyle textgris = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.gris1,
  );

  //Texte gris 2
  static const TextStyle textgris2 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.gris3,
  );

  // Texte noir
  static const TextStyle textnoir = TextStyle(
    fontSize: 13,
    color: Colors.black,
  );
}
