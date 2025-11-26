import 'package:flutter/material.dart';
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_buttons.dart';

class AppDialogs {
  static Future<void> showCrudDialog({
    required BuildContext context,
    required String title,
    required String confirmText,
    required List<Widget> fields,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleSection.copyWith(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          AppButtons.dialogPrimary(
            text: confirmText,
            onTap: () async => await onConfirm(),
          ),
        ],
      ),
    );
  }
}
