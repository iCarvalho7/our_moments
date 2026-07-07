import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/metadata_row.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../page/location_picker_page.dart';
import 'audio_section.dart';

/// The "when / where / voice note" metadata block on the moment sheet. Each row
/// is a compact tappable entry that opens the matching picker and dispatches the
/// same events the old full-height sections used.
class MomentMetaRows extends StatelessWidget {
  const MomentMetaRows({super.key, this.lastDate});

  /// When set, the date picker will not allow selecting a date after this value.
  /// Used to enforce the timeline's end date constraint.
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        final moment = state.moment;
        final isPlaceholderDate = moment.dateTime == AddOrEditMomentBloc.defaultDateTime;
        final hasTime = !isPlaceholderDate &&
            (moment.dateTime.hour != 0 || moment.dateTime.minute != 0);
        final dateValue = isPlaceholderDate
            ? 'Adicionar data e hora'
            : (hasTime
                ? '${moment.dateTimeComplete} · ${_timeLabel(moment.dateTime)}'
                : moment.dateTimeComplete);

        return MetadataCard(
          children: [
            MetadataRow(
              key: const ValueKey('key_moment_form_date_selector'),
              icon: Icons.calendar_today_rounded,
              label: 'Quando aconteceu',
              value: dateValue,
              active: !isPlaceholderDate,
              onTap: () => _pickDateTime(context),
            ),
            MetadataRow(
              icon: moment.hasLocation ? Icons.place_rounded : Icons.place_outlined,
              label: 'Onde foi',
              value: moment.locationName.isNotEmpty ? moment.locationName : 'Adicionar local',
              active: moment.hasLocation || moment.locationName.isNotEmpty,
              onTap: () => _pickLocation(context),
            ),
            MetadataRow(
              icon: moment.hasAudio ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
              label: 'Recado de voz',
              value: moment.hasAudio ? 'Recado adicionado' : 'Gravar um recado',
              active: moment.hasAudio,
              onTap: () => _openAudioSheet(context),
              showDivider: false,
            ),
          ],
        );
      },
    );
  }

  String _timeLabel(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDateTime(BuildContext context) async {
    final bloc = context.read<AddOrEditMomentBloc>();
    final current = bloc.state.moment.dateTime;
    final hasDate = current != AddOrEditMomentBloc.defaultDateTime;

    final effectiveLast = lastDate ?? DateTime.now();
    final now = DateTime.now();
    final safeInitial = hasDate
        ? (current.isAfter(effectiveLast) ? effectiveLast : current)
        : (now.isAfter(effectiveLast) ? effectiveLast : now);

    final date = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: DateTime(2018, 1, 1),
      lastDate: effectiveLast,
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: hasDate ? TimeOfDay.fromDateTime(current) : TimeOfDay.now(),
    );

    final combined =
        DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
    bloc.add(AddOrEditMomentEventAddDateTime(date: combined));
  }

  Future<void> _pickLocation(BuildContext context) async {
    final bloc = context.read<AddOrEditMomentBloc>();
    final moment = bloc.state.moment;
    final result = await Navigator.of(context).pushNamed(
      AppRoute.locationPicker.tag,
      arguments: (initialLatitude: moment.latitude, initialLongitude: moment.longitude, initialName: moment.locationName),
    ) as PickedLocation?;
    if (result != null) {
      bloc.add(AddOrEditMomentEventSetLocation(
        latitude: result.latitude,
        longitude: result.longitude,
        name: result.name,
      ));
    }
  }

  Future<void> _openAudioSheet(BuildContext context) async {
    final bloc = context.read<AddOrEditMomentBloc>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recado de voz',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              kSpacerHeight12,
              const AudioSection(),
              kSpacerHeight8,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Concluir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
