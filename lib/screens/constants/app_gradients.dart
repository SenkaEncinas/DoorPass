import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  const AppGradients._();

  // Gradiente principal para botones / elementos destacados
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente del search bar y contenedores suaves
  static LinearGradient searchBar = LinearGradient(
    colors: [
      AppColors.primaryAccent.withOpacity(0.6),
      AppColors.secondaryAccent.withOpacity(0.6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
