import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_network_image.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_button.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../domain/entity/time_capsule.dart';
import '../bloc/time_capsule_bloc.dart';

/// Couple-only time capsule ("Cápsula do tempo"). Capsules live in the
/// `time_line/{id}/time_capsules` subcollection. Reveal is client-side: locked
/// capsules never expose their message until [TimeCapsule.revealDate].
typedef _TimeCapsuleArgs = ({String timelineId, List<String> emails});

class TimeCapsulePage extends StatelessWidget {
  const TimeCapsulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as _TimeCapsuleArgs?;
    final timelineId = args?.timelineId ?? '';
    final emails = args?.emails ?? const [];
    return BlocProvider<TimeCapsuleBloc>(
      create: (_) => getIt<TimeCapsuleBloc>()
        ..add(TimeCapsuleStarted(timelineId: timelineId, emails: emails)),
      child: const _TimeCapsuleView(),
    );
  }
}

class _TimeCapsuleView extends StatelessWidget {
  const _TimeCapsuleView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PrimaryAppBar(title: 'Cápsula do tempo'),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddSheet(context),
            child: const Icon(Icons.add_rounded),
          ),
          body: BlocBuilder<TimeCapsuleBloc, TimeCapsuleState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.capsules.isEmpty) {
                return _EmptyState(onAdd: () => _openAddSheet(context));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: state.capsules
                    .map((c) => _CapsuleTile(capsule: c))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openAddSheet(BuildContext context) {
    final bloc = context.read<TimeCapsuleBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddCapsuleSheet(
        onSubmit: (message, revealDate) {
          bloc.add(TimeCapsuleAdded(message: message, revealDate: revealDate));
        },
      ),
    );
  }
}

class _CapsuleTile extends StatelessWidget {
  const _CapsuleTile({required this.capsule});

  final TimeCapsule capsule;

  int get _daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reveal = DateTime(
      capsule.revealDate.year,
      capsule.revealDate.month,
      capsule.revealDate.day,
    );
    return reveal.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bloc = context.read<TimeCapsuleBloc>();
    final revealed = capsule.isRevealedAt(DateTime.now());
    final formatted =
        DateFormat('dd/MM/yyyy', 'pt_BR').format(capsule.revealDate);

    return Dismissible(
      key: ValueKey(capsule.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => bloc.add(TimeCapsuleRemoved(capsule.id)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: palette.danger.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Icon(Icons.delete_outline_rounded, color: palette.danger),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: palette.outline),
        ),
        child: revealed
            ? _RevealedContent(capsule: capsule, formatted: formatted)
            : _LockedContent(formatted: formatted, daysUntil: _daysUntil),
      ),
    );
  }
}

class _LockedContent extends StatelessWidget {
  const _LockedContent({required this.formatted, required this.daysUntil});

  final String formatted;
  final int daysUntil;

  String get _countdown {
    if (daysUntil <= 0) return 'Abre hoje';
    if (daysUntil == 1) return 'Abre amanhã';
    return 'Faltam $daysUntil dias';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.primarySoft,
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          child: Icon(Icons.lock_outline_rounded, color: palette.primary),
        ),
        kSpacerWidth12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cápsula trancada', style: textTheme.titleMedium),
              kSpacerHeight8,
              Text(
                '$_countdown · abre em $formatted',
                style: textTheme.bodySmall?.copyWith(color: palette.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RevealedContent extends StatelessWidget {
  const _RevealedContent({required this.capsule, required this.formatted});

  final TimeCapsule capsule;
  final String formatted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.mark_email_read_outlined, color: palette.primary),
            kSpacerWidth8,
            Expanded(
              child: Text('Cápsula revelada', style: textTheme.titleMedium),
            ),
          ],
        ),
        if (capsule.mediaUrl.isNotEmpty) ...[
          kSpacerHeight12,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.input),
            child: AppNetworkImage(
              url: capsule.mediaUrl,
              height: 180,
              width: double.infinity,
              errorWidget: Container(
                height: 180,
                color: palette.primarySoft,
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined, color: palette.primary),
              ),
            ),
          ),
        ],
        kSpacerHeight12,
        Text(capsule.message, style: textTheme.bodyLarge),
        kSpacerHeight8,
        Text(
          'Revelada em $formatted',
          style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline_rounded,
                size: 48, color: palette.onSurfaceMuted),
            kSpacerHeight16,
            Text('Nenhuma cápsula ainda', style: textTheme.titleMedium),
            kSpacerHeight8,
            Text(
              'Escreva um recado surpresa para ser revelado em uma data futura.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
            kSpacerHeight24,
            PrimaryButton(label: 'Criar cápsula', onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}

class _AddCapsuleSheet extends StatefulWidget {
  const _AddCapsuleSheet({required this.onSubmit});

  final void Function(String message, DateTime revealDate) onSubmit;

  @override
  State<_AddCapsuleSheet> createState() => _AddCapsuleSheetState();
}

class _AddCapsuleSheetState extends State<_AddCapsuleSheet> {
  final _messageController = TextEditingController();
  DateTime _revealDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    widget.onSubmit(message, _revealDate);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nova cápsula do tempo', style: textTheme.headlineSmall),
              kSpacerHeight16,
              TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Seu recado surpresa',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
              ),
              kSpacerHeight16,
              Text('Revelar em', style: textTheme.titleSmall),
              kSpacerHeight8,
              SizedBox(
                height: 300,
                child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.single,
                  initialSelectedDate: _revealDate,
                  minDate: DateTime.now(),
                  allowViewNavigation: true,
                  backgroundColor: Colors.transparent,
                  todayHighlightColor: palette.primary,
                  selectionColor: palette.primary,
                  selectionTextStyle: TextStyle(
                    color: palette.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: Colors.transparent,
                    textStyle: textTheme.titleMedium,
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: textTheme.bodyMedium,
                  ),
                  onSelectionChanged: (args) {
                    if (args.value is DateTime) {
                      _revealDate = args.value as DateTime;
                    }
                  },
                ),
              ),
              kSpacerHeight16,
              PrimaryButton(label: 'Guardar cápsula', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
