import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

/// Bottom sheet shown when a member chooses to leave a shared timeline.
/// Lets them optionally delete the moments they authored (LGPD) and confirms
/// the (destructive) leave action via [onConfirm].
class LeaveTimelineSheet extends StatefulWidget {
  const LeaveTimelineSheet({
    super.key,
    required this.timelineName,
    required this.onConfirm,
  });

  final String timelineName;

  /// Called with whether the user asked to also delete their authored moments.
  final ValueChanged<bool> onConfirm;

  @override
  State<LeaveTimelineSheet> createState() => _LeaveTimelineSheetState();
}

class _LeaveTimelineSheetState extends State<LeaveTimelineSheet> {
  bool _deleteAuthoredMoments = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;
    final name = widget.timelineName.trim();

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Icon(Icons.logout_rounded, color: errorColor, size: 24),
              ),
              kSpacerWidth12,
              const Expanded(
                child: Text('Sair da timeline?'),
              ),
            ],
          ),
          kSpacerHeight16,
          Text(
            name.isEmpty
                ? 'Você deixará de ter acesso a esta linha do tempo. Os demais membros continuarão com ela.'
                : 'Você deixará de ter acesso a "$name". Os demais membros continuarão com ela.',
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
          ),
          kSpacerHeight24,
          InkWell(
            onTap: () => setState(
                () => _deleteAuthoredMoments = !_deleteAuthoredMoments),
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
                      value: _deleteAuthoredMoments,
                      onChanged: (v) => setState(
                          () => _deleteAuthoredMoments = v ?? false),
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
                      child: Text(
                        'Excluir os momentos que criei nesta timeline',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          kSpacerHeight16,
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.privacy_tip_outlined,
                    size: 18, color: palette.onSurfaceMuted),
                kSpacerWidth12,
                Expanded(
                  child: Text(
                    'Você tem o direito de solicitar a exclusão dos seus dados, '
                    'incluindo fotos íntimas, conforme a LGPD e o Marco Civil da '
                    'Internet.',
                    style: textTheme.bodySmall
                        ?.copyWith(color: palette.onSurfaceMuted),
                  ),
                ),
              ],
            ),
          ),
          kSpacerHeight32,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onConfirm(_deleteAuthoredMoments);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair da timeline'),
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
