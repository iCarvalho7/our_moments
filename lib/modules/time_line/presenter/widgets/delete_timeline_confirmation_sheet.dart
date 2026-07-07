import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class DeleteTimelineConfirmationSheet extends StatefulWidget {
  const DeleteTimelineConfirmationSheet({
    super.key,
    required this.timelineName,
    required this.onConfirm,
  });

  final String timelineName;
  final VoidCallback onConfirm;

  @override
  State<DeleteTimelineConfirmationSheet> createState() =>
      _DeleteTimelineConfirmationSheetState();
}

class _DeleteTimelineConfirmationSheetState
    extends State<DeleteTimelineConfirmationSheet> {
  int _step = 0;
  bool _check1 = false;
  bool _check2 = false;
  bool _forward = true;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canProceed => _check1 && _check2;
  bool get _canDelete {
    final typed = _nameController.text.trim();
    return typed.isNotEmpty && typed == widget.timelineName.trim();
  }

  void _goToStep2() => setState(() {
        _forward = true;
        _step = 1;
      });

  void _goBackToStep1() => setState(() {
        _forward = false;
        _step = 0;
      });

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: palette.outline,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          kSpacerHeight24,
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              final offsetTween = Tween<Offset>(
                begin: Offset(_forward ? 0.15 : -0.15, 0),
                end: Offset.zero,
              );
              return SlideTransition(
                position: offsetTween.animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _step == 0
                ? _Step1(
                    key: const ValueKey('step1'),
                    palette: palette,
                    textTheme: textTheme,
                    errorColor: errorColor,
                    check1: _check1,
                    check2: _check2,
                    canProceed: _canProceed,
                    onCheck1: (v) => setState(() => _check1 = v ?? false),
                    onCheck2: (v) => setState(() => _check2 = v ?? false),
                    onContinue: _goToStep2,
                    onCancel: () => Navigator.of(context).pop(),
                  )
                : _Step2(
                    key: const ValueKey('step2'),
                    palette: palette,
                    textTheme: textTheme,
                    errorColor: errorColor,
                    timelineName: widget.timelineName,
                    nameController: _nameController,
                    canDelete: _canDelete,
                    onChanged: () => setState(() {}),
                    onDelete: () {
                      Navigator.of(context).pop();
                      widget.onConfirm();
                    },
                    onBack: _goBackToStep1,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  const _Step1({
    super.key,
    required this.palette,
    required this.textTheme,
    required this.errorColor,
    required this.check1,
    required this.check2,
    required this.canProceed,
    required this.onCheck1,
    required this.onCheck2,
    required this.onContinue,
    required this.onCancel,
  });

  final AppPalette palette;
  final TextTheme textTheme;
  final Color errorColor;
  final bool check1;
  final bool check2;
  final bool canProceed;
  final ValueChanged<bool?> onCheck1;
  final ValueChanged<bool?> onCheck2;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_amber_rounded, color: errorColor, size: 24),
            ),
            kSpacerWidth12,
            Expanded(
              child: Text(
                'Deletar linha do tempo?',
                style: textTheme.titleLarge,
              ),
            ),
          ],
        ),
        kSpacerHeight16,
        Text(
          'Esta ação é permanente e irrecuperável. Todos os momentos, fotos e dados desta linha do tempo serão perdidos.',
          style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
        ),
        kSpacerHeight24,
        _CheckRow(
          value: check1,
          onChanged: onCheck1,
          label: 'Entendo que todos os momentos serão deletados permanentemente',
          palette: palette,
          textTheme: textTheme,
          errorColor: errorColor,
        ),
        kSpacerHeight12,
        _CheckRow(
          value: check2,
          onChanged: onCheck2,
          label: 'Entendo que esta ação não pode ser desfeita',
          palette: palette,
          textTheme: textTheme,
          errorColor: errorColor,
        ),
        kSpacerHeight32,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: errorColor.withValues(alpha: 0.38),
            ),
            child: const Text('Continuar'),
          ),
        ),
        kSpacerHeight8,
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onCancel,
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}

class _Step2 extends StatelessWidget {
  const _Step2({
    super.key,
    required this.palette,
    required this.textTheme,
    required this.errorColor,
    required this.timelineName,
    required this.nameController,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
    required this.onBack,
  });

  final AppPalette palette;
  final TextTheme textTheme;
  final Color errorColor;
  final String timelineName;
  final TextEditingController nameController;
  final bool canDelete;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_forever_rounded, color: errorColor, size: 24),
            ),
            kSpacerWidth12,
            Expanded(
              child: Text(
                'Tem certeza absoluta?',
                style: textTheme.titleLarge,
              ),
            ),
          ],
        ),
        kSpacerHeight16,
        Text(
          'Para confirmar, digite o nome exato da linha do tempo:',
          style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
        ),
        kSpacerHeight12,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(color: palette.outline),
          ),
          child: Text(
            timelineName.isEmpty ? '(sem nome)' : timelineName,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: timelineName.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        kSpacerHeight16,
        TextField(
          controller: nameController,
          onChanged: (_) => onChanged(),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Digite o nome aqui',
            prefixIcon: const Icon(Icons.drive_file_rename_outline),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide: BorderSide(color: canDelete ? errorColor : palette.primary),
            ),
          ),
        ),
        kSpacerHeight8,
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: palette.onSurfaceMuted),
            const SizedBox(width: 6),
            Text(
              'Diferencia letras maiúsculas de minúsculas',
              style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
            ),
          ],
        ),
        kSpacerHeight32,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const ValueKey('key_timeline_delete_confirm_button'),
            onPressed: canDelete ? onDelete : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: errorColor.withValues(alpha: 0.38),
            ),
            child: const Text('Deletar linha do tempo'),
          ),
        ),
        kSpacerHeight8,
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Voltar'),
          ),
        ),
      ],
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
                child: Text(
                  label,
                  style: textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
