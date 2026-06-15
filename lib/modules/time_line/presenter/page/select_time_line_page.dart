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
          BlocBuilder<SelectTimeLineBloc, SelectTimeLineState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () {
                  context.read<SelectTimeLineBloc>().add(SelectTimeLineEventFetchAll());
                  return Future.value();
                },
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: PrimaryAppBar(
                    title: 'Linha do Tempo',
                    back: IconButton(
                      onPressed: () {
                        context.read<SelectTimeLineBloc>().add(SelectTimeLineEventLogout());
                      },
                      icon: const Icon(Icons.logout),
                    ),
                  ),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BlocConsumer<SelectTimeLineBloc, SelectTimeLineState>(
                        listener: listenerChanges,
                        builder: (context, state) {
                          if (state is SelectTimeLineLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (state is SelectTimeLineEmpty || state is SelectTimeLineError) {
                            return const _CreateTimeLineContent();
                          }

                          if (state is SelectTimeLineSuccess) {
                            return Column(
                              children: [
                                ListView.builder(
                                  itemCount: state.timeLines.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final item = state.timeLines[index];
                                    return _SelectTimeLineItem(item: item);
                                  },
                                ),
                                SizedBox(height: 32),
                                _CreateTimeLineContent(),
                              ],
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void listenerChanges(BuildContext context, SelectTimeLineState state) {
    if (state is SelectTimeLogoutSuccess) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.login.tag, (Route<dynamic> route) => false);
    }

    if (state is SelectTimeLineError) {
      final msm = kDebugMode ? state.error : 'Erro ao Criar sua linha do tempo';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(msm),
        ),
      );
    }
  }
}

class _SelectTimeLineItem extends StatelessWidget {
  const _SelectTimeLineItem({required this.item});

  final TimeLine item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AppCard(
        onTap: () {
          final bloc = context.read<SelectTimeLineBloc>();
          Navigator.pushNamed(context, AppRoute.timeLine.tag, arguments: item.id).then((e) {
            bloc.add(SelectTimeLineEventFetchAll());
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.emailsFormatted
                        .map((e) => Text(e, style: textTheme.titleSmall))
                        .toList(),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item.dateMonth, textAlign: TextAlign.end, style: textTheme.titleSmall),
                    Text(
                      item.momentsAmount,
                      style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Text(
                  'Ver os momentos',
                  style: textTheme.titleSmall?.copyWith(color: palette.primary),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: palette.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTimeLineContent extends StatelessWidget {
  const _CreateTimeLineContent();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: SizedBox.shrink()),
          AppCard(
            onTap: () {
              final bloc = context.read<SelectTimeLineBloc>();
              Navigator.pushNamed(context, AppRoute.timeLine.tag)
                  .then((_) => bloc.add(SelectTimeLineEventFetchAll()));
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Criar sua linha do tempo', style: textTheme.titleLarge),
                      kSpacerHeight8,
                      Text(
                        'Crie seus momentos e compartilhe com quem quiser.',
                        style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
                kSpacerWidth16,
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: palette.primary),
                ),
              ],
            ),
          ),
          kSpacerHeight16,
          Text(
            '* Para ver uma linha do tempo existente, você precisa pedir acesso ao criador(a) da linha do tempo.',
            style: textTheme.bodySmall,
          ),
          const Expanded(child: SizedBox.shrink()),
          Container(
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
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
