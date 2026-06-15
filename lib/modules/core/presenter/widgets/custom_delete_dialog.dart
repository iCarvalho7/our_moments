import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

class CustomDeleteDialog extends StatelessWidget {
  const CustomDeleteDialog({
    required this.text,
    required this.onTapPositive,
    super.key,
  });

  final String text;
  final VoidCallback onTapPositive;

  static void show(
    BuildContext parentContext, {
    required String text,
    required VoidCallback onTapPositive,
  }) {
    showDialog(
      context: parentContext,
      builder: (context) {
        return CustomDeleteDialog(text: text, onTapPositive: onTapPositive);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline_rounded, color: palette.danger, size: 32),
          ),
          kSpacerHeight16,
          Text(text, textAlign: TextAlign.center, style: textTheme.bodyLarge),
          kSpacerHeight24,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: palette.surfaceAlt,
                    foregroundColor: palette.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Não'),
                ),
              ),
              kSpacerWidth12,
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onTapPositive,
                  child: const Text('Sim'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
