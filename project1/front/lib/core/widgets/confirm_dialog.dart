import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';

enum ConfirmDialogVariant { defaultVariant, danger }

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? warningMessage;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final ConfirmDialogVariant variant;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.warningMessage,
    required this.confirmText,
    this.cancelText = '취소',
    required this.onConfirm,
    this.variant = ConfirmDialogVariant.defaultVariant,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? warningMessage,
    required String confirmText,
    String cancelText = '취소',
    required VoidCallback onConfirm,
    ConfirmDialogVariant variant = ConfirmDialogVariant.defaultVariant,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        warningMessage: warningMessage,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        variant: variant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.background,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.mutedForeground,
                      ),
                    ),

                    if (warningMessage != null) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          warningMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        foregroundColor: Colors.black54,
                      ),
                      child: Text(cancelText),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: variant == ConfirmDialogVariant.danger
                            ? Colors.red.shade800
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}