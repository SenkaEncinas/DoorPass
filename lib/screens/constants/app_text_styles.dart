import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static final TextStyle titleLarge = GoogleFonts.orbitron(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle titleSection = GoogleFonts.orbitron(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle body = GoogleFonts.orbitron(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  static final TextStyle subtitle = GoogleFonts.orbitron(
    color: AppColors.textSecondary,
    fontSize: 13,
  );

  static final TextStyle button = GoogleFonts.orbitron(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle searchText = GoogleFonts.orbitron(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  static final TextStyle searchHint = GoogleFonts.orbitron(
    color: AppColors.textSecondary.withOpacity(0.7),
    fontSize: 13,
  );

  static final TextStyle emptyState = GoogleFonts.orbitron(
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle historyButton = GoogleFonts.orbitron(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
}
