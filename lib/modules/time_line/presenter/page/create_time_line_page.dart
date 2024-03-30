import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
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
      create: (_) =>
          getIt<SelectTimeLineBloc>()..add(SelectTimeLineEventFetchAll()),
      child: Stack(
        children: [
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PrimaryAppBar(
              title: 'Linha do Tempo',
              back: BlocBuilder<SelectTimeLineBloc, SelectTimeLineState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: () {
                      context
                          .read<SelectTimeLineBloc>()
                          .add(SelectTimeLineEventLogout());
                    },
                    icon: const Icon(Icons.logout),
                  );
                },
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

                    if (state is SelectTimeLineEmpty ||
                        state is SelectTimeLineError) {
                      return const _CreateTimeLineContent();
                    }

                    if (state is SelectTimeLineSuccess) {
                      return ListView.builder(
                        itemCount: state.timeLines.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item = state.timeLines[index];
                          return _SelectTimeLineItem(item: item);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void listenerChanges(BuildContext context, SelectTimeLineState state) {
    if (state is SelectTimeLogoutSuccess) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoute.login.tag, (Route<dynamic> route) => false);
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.timeLine.tag, arguments: item);
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 8.0,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: item.emailsFormatted
                          .map(
                            (e) => Text(
                              e,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          )
                          .toList(),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.dateMonth,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          item.momentsAmount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Ver os momentos',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    SvgPicture.asset('assets/images/eyes.svg')
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTimeLineContent extends StatelessWidget {
  const _CreateTimeLineContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoute.timeLine.tag).then((_) =>
                context
                    .read<SelectTimeLineBloc>()
                    .add(SelectTimeLineEventFetchAll()));
          },
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Criar sua Linha do Tempo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  kSpacerWidth16,
                  SvgPicture.asset('assets/images/player_next.svg')
                ],
              ),
              Text(
                'Aqui você pode criar seus momentos e compartilhar com quem quiser',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '* Ver uma linha do tempo existente',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'Você precisa pedir acesso ao criador(a) da linha do tempo.\n',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Spacer(flex: 1),
        Row(
          children: [
            const Icon(Icons.warning_rounded),
            kSpacerWidth16,
            Flexible(
              child: Text(
                'Caso tenha perdido acesso a sua linha do tempo, entre em contato : contato.lutestudios@gmail.com',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
