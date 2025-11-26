import 'package:flutter/material.dart';
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';
import 'package:google_fonts/google_fonts.dart';

class AppButtons {
  static Widget primary({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.softCard,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                text,
                style: GoogleFonts.orbitron(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget smallGradient({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.textPrimary),
                const SizedBox(width: 4),
              ],
              Text(
                text,
                style: GoogleFonts.orbitron(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget dialogPrimary({
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: GoogleFonts.orbitron(fontSize: 13),
      ),
    );
  }
}
