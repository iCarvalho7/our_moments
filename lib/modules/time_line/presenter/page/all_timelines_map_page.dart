import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/all_timelines_map_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/road_timeline.dart';

class AllTimelinesMapPage extends StatelessWidget {
  const AllTimelinesMapPage({super.key});

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
            body: BlocBuilder<AllTimelinesMapBloc, AllTimelinesMapState>(
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
                  return RoadTimeline(
                    moments:        state.moments,
                    timelineColors: colors,
                    timelineNames:  names,
                    onMomentTap: (moment) {
                      final accentColor =
                          state.timelineAccentColors[moment.timelineId];
                      final mapBloc = context.read<AllTimelinesMapBloc>();
                      context.read<AddOrEditMomentBloc>().add(
                            SetupEditMomentEvent(moment: moment),
                          );
                      Navigator.pushNamed(
                        context,
                        AppRoute.addMoment.tag,
                        arguments: (accentColor: accentColor, endDate: null),
                      ).then((_) => mapBloc.add(FetchAllTimelinesMapEvent()));
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
              color:        palette.surface,
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
    final palette   = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_outlined,
              size: 52, color: palette.onSurfaceMuted),
          const SizedBox(height: 16),
          Text('Nenhum momento ainda', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Crie momentos nas suas linhas do tempo.',
            style: textTheme.bodyMedium
                ?.copyWith(color: palette.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
