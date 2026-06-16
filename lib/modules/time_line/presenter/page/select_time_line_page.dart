import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_card.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/select_time_line_bloc.dart';

class SelectTimeLinePage extends StatelessWidget {
  const SelectTimeLinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SelectTimeLineBloc>()..add(SelectTimeLineEventFetchAll()),
      child: Stack(
        children: [
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PrimaryAppBar(
              title: 'Linhas do tempo',
              back: IconButton(
                tooltip: 'Sair',
                onPressed: () {
                  context.read<SelectTimeLineBloc>().add(SelectTimeLineEventLogout());
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
            body: SafeArea(
              child: BlocConsumer<SelectTimeLineBloc, SelectTimeLineState>(
                listener: listenerChanges,
                builder: (context, state) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<SelectTimeLineBloc>().add(SelectTimeLineEventFetchAll());
                    },
                    child: _buildBody(context, state),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SelectTimeLineState state) {
    if (state is SelectTimeLineLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SelectTimeLineSuccess && state.timeLines.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Intro(count: state.timeLines.length),
          kSpacerHeight16,
          ...state.timeLines.map((item) => _SelectTimeLineItem(item: item)),
          kSpacerHeight8,
          const _CreateTimeLineCard(),
          kSpacerHeight24,
          const _HelpNote(),
        ],
      );
    }

    // Empty / error → onboarding to create the first timeline.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _EmptyHero(),
        kSpacerHeight24,
        const _CreateTimeLineCard(),
        kSpacerHeight16,
        Text(
          'Para ver uma linha do tempo existente, peça acesso a quem a criou.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.onSurfaceMuted,
              ),
        ),
        kSpacerHeight24,
        const _HelpNote(),
      ],
    );
  }

  void listenerChanges(BuildContext context, SelectTimeLineState state) {
    if (state is SelectTimeLogoutSuccess) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoute.login.tag, (Route<dynamic> route) => false);
    }

    if (state is SelectTimeLineError) {
      final msm = kDebugMode ? state.error : 'Erro ao criar sua linha do tempo';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(msm)),
      );
    }
  }
}

/// Greeting line above the list.
class _Intro extends StatelessWidget {
  const _Intro({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suas memórias', style: textTheme.headlineMedium),
        kSpacerHeight8,
        Text(
          count == 1 ? '1 linha do tempo' : '$count linhas do tempo',
          style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _SelectTimeLineItem extends StatelessWidget {
  const _SelectTimeLineItem({required this.item});

  final TimeLine item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final accent = item.accentColor != null ? Color(item.accentColor!) : palette.primary;
    final name = item.name.isNotEmpty ? item.name : 'Nossa linha do tempo';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AppCard(
        onTap: () {
          final bloc = context.read<SelectTimeLineBloc>();
          Navigator.pushNamed(context, AppRoute.timeLine.tag, arguments: item.id)
              .then((e) => bloc.add(SelectTimeLineEventFetchAll()));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AccentTile(color: accent),
                kSpacerWidth16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.momentsAmount} · ${item.dateMonth}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                _AvatarStack(emails: item.emails, color: accent),
                const Spacer(),
                Text(
                  'Ver os momentos',
                  style: textTheme.titleSmall?.copyWith(color: accent),
                ),
                Icon(Icons.chevron_right_rounded, color: accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded accent square with a heart, identifying a timeline by its color.
class _AccentTile extends StatelessWidget {
  const _AccentTile({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.white, 0.25) ?? color],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
    );
  }
}

/// Overlapping initial-avatars for the people sharing a timeline.
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.emails, required this.color});

  final List<String> emails;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shown = emails.take(3).toList();
    const size = 30.0;
    const overlap = 20.0;
    final extra = emails.length - shown.length;

    return SizedBox(
      height: size,
      width: shown.isEmpty ? 0 : size + (shown.length - 1) * overlap + (extra > 0 ? overlap : 0),
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: _Avatar(
                letter: shown[i].isNotEmpty ? shown[i][0].toUpperCase() : '?',
                color: color,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.onSurfaceMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter, required this.color});

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: palette.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Eye-catching gradient card that starts the create-timeline flow.
class _CreateTimeLineCard extends StatelessWidget {
  const _CreateTimeLineCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return GestureDetector(
      onTap: () {
        final bloc = context.read<SelectTimeLineBloc>();
        Navigator.pushNamed(context, AppRoute.timeLine.tag)
            .then((_) => bloc.add(SelectTimeLineEventFetchAll()));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [palette.primary, palette.secondaryAccent]),
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.soft(context),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: palette.primary, size: 28),
            ),
            kSpacerWidth16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Criar nova linha do tempo',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registre seus momentos e compartilhe com quem quiser.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero shown when the user has no timelines yet.
class _EmptyHero extends StatelessWidget {
  const _EmptyHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: palette.primarySoft, shape: BoxShape.circle),
            child: Icon(Icons.favorite_rounded, color: palette.primary, size: 44),
          ),
          kSpacerHeight24,
          Text('Comece sua história', style: textTheme.headlineMedium, textAlign: TextAlign.center),
          kSpacerHeight8,
          Text(
            'Crie sua primeira linha do tempo para guardar e reviver os momentos de vocês.',
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// "Lost access?" support note.
class _HelpNote extends StatelessWidget {
  const _HelpNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: palette.onSurfaceMuted),
          kSpacerWidth12,
          Flexible(
            child: Text(
              'Perdeu acesso à sua linha do tempo? Fale com: contato.lutestudios@gmail.com',
              style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}
