import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/all_timelines_map_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/road_timeline.dart';

class AllTimelinesMapPage extends StatefulWidget {
  const AllTimelinesMapPage({super.key});

  @override
  State<AllTimelinesMapPage> createState() => _AllTimelinesMapPageState();
}

class _AllTimelinesMapPageState extends State<AllTimelinesMapPage> {
  String? _activeTimelineId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllTimelinesMapBloc>(
      create: (_) =>
          getIt<AllTimelinesMapBloc>()..add(FetchAllTimelinesMapEvent()),
      child: Stack(
        children: [
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PrimaryAppBar(title: 'Todos os momentos'),
            body: SafeArea(
              top: false,
              child: BlocBuilder<AllTimelinesMapBloc, AllTimelinesMapState>(
                builder: (context, state) {
                  if (state is AllTimelinesMapLoading) {
                    return const _LoadingBody();
                  }
                  if (state is AllTimelinesMapEmpty) {
                    return const _EmptyBody();
                  }
                  if (state is AllTimelinesMapSuccess) {
                    final colors = {
                      for (final e in state.timelineAccentColors.entries)
                        if (e.value != null) e.key: Color(e.value!),
                    };
                    final names = {
                      for (final t in state.timelines) t.id: t.name,
                    };
                    final filtered = _activeTimelineId == null
                        ? state.moments
                        : state.moments
                              .where((m) => m.timelineId == _activeTimelineId)
                              .toList();
                    return Column(
                      children: [
                        _TimelineFilterRow(
                          timelines: state.timelines,
                          accentColors: colors,
                          activeId: _activeTimelineId,
                          onSelect: (id) =>
                              setState(() => _activeTimelineId = id),
                        ),
                        Expanded(
                          child: filtered.isEmpty
                              ? const _EmptyFilterBody()
                              : RoadTimeline(
                                  moments: filtered,
                                  timelineColors: colors,
                                  timelineNames: names,
                                  onMomentTap: (moment) {
                                    final accentColor =
                                        state.timelineAccentColors[moment
                                            .timelineId];
                                    final mapBloc = context
                                        .read<AllTimelinesMapBloc>();
                                    context.read<AddOrEditMomentBloc>().add(
                                      SetupEditMomentEvent(moment: moment),
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      AppRoute.addMoment.tag,
                                      arguments: (
                                        accentColor: accentColor,
                                        endDate: null,
                                      ),
                                    ).then(
                                      (_) => mapBloc.add(
                                        FetchAllTimelinesMapEvent(),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineFilterRow extends StatelessWidget {
  const _TimelineFilterRow({
    required this.timelines,
    required this.accentColors,
    required this.activeId,
    required this.onSelect,
  });

  final List<TimeLine> timelines;
  final Map<String, Color> accentColors;
  final String? activeId;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _FilterChip(
            label: 'Todas',
            accent: palette.primary,
            selected: activeId == null,
            onTap: () => onSelect(null),
            textTheme: textTheme,
          ),
          ...timelines.map((tl) {
            final accent = accentColors[tl.id] ?? palette.primary;
            final name = tl.name.isNotEmpty ? tl.name : 'História';
            return _FilterChip(
              label: name,
              accent: accent,
              selected: activeId == tl.id,
              onTap: () => onSelect(tl.id),
              textTheme: textTheme,
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
    required this.textTheme,
  });

  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? accent : accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : accent,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LoadingEffect(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 52,
            color: palette.onSurfaceMuted,
          ),
          const SizedBox(height: 16),
          Text('Nenhum momento ainda', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Crie momentos nas suas histórias.',
            style: textTheme.bodyMedium?.copyWith(
              color: palette.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterBody extends StatelessWidget {
  const _EmptyFilterBody();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            size: 52,
            color: palette.onSurfaceMuted,
          ),
          const SizedBox(height: 16),
          Text('Nenhum momento nesta história', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Selecione outra história ou "Todas".',
            style: textTheme.bodyMedium?.copyWith(
              color: palette.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
