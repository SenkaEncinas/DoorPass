import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  // Sombra suave tipo "neón" para cards
  static List<BoxShadow> softCard = [
    BoxShadow(
      color: AppColors.primaryAccent.withOpacity(0.2),
      blurRadius: 12,
      spreadRadius: 1,
      offset: const Offset(0, 6),
    ),
  ];
}
