import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

/// Confirmation bottom sheet for permanently deleting the user's account.
/// Requires acknowledging two consequences before the delete button enables.
/// Calls [onConfirm] after popping itself.
class DeleteAccountConfirmationSheet extends StatefulWidget {
  const DeleteAccountConfirmationSheet({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  State<DeleteAccountConfirmationSheet> createState() =>
      _DeleteAccountConfirmationSheetState();
}

class _DeleteAccountConfirmationSheetState
    extends State<DeleteAccountConfirmationSheet> {
  bool _check1 = false;
  bool _check2 = false;

  bool get _canDelete => _check1 && _check2;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.card),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.outline,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          kSpacerHeight24,
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_off_outlined, color: errorColor, size: 24),
              ),
              kSpacerWidth12,
              Expanded(
                child: Text('Excluir sua conta?', style: textTheme.titleLarge),
              ),
            ],
          ),
          kSpacerHeight16,
          Text(
            'Esta ação é permanente e não pode ser desfeita. Sua conta será '
            'apagada e todas as linhas do tempo em que você é o único membro, '
            'com seus momentos e fotos, serão perdidas para sempre.',
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
          ),
          kSpacerHeight24,
          _CheckRow(
            value: _check1,
            onChanged: (v) => setState(() => _check1 = v ?? false),
            label: 'Entendo que minha conta e meus dados serão apagados '
                'permanentemente',
            palette: palette,
            textTheme: textTheme,
            errorColor: errorColor,
          ),
          kSpacerHeight12,
          _CheckRow(
            value: _check2,
            onChanged: (v) => setState(() => _check2 = v ?? false),
            label: 'Entendo que esta ação não pode ser desfeita',
            palette: palette,
            textTheme: textTheme,
            errorColor: errorColor,
          ),
          kSpacerHeight32,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canDelete
                  ? () {
                      Navigator.of(context).pop();
                      widget.onConfirm();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: errorColor.withValues(alpha: 0.38),
              ),
              child: const Text('Excluir conta'),
            ),
          ),
          kSpacerHeight8,
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.palette,
    required this.textTheme,
    required this.errorColor,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final AppPalette palette;
  final TextTheme textTheme;
  final Color errorColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadii.input),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            kSpacerWidth12,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(label, style: textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
