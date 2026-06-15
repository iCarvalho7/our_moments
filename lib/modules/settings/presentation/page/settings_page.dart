import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/login/presentation/widget/login_text_field.dart';
import 'package:nossos_momentos/modules/settings/presentation/bloc/settings_bloc.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';

import '../../../core/presenter/widgets/background_gradient.dart';
import '../../../core/utils/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final timeLineId = ModalRoute.of(context)?.settings.arguments as String;

    return BlocProvider<SettingsBloc>(
      create: (context) => getIt<SettingsBloc>()..add(FetchEmailEvent(timeLineId: timeLineId)),
      child: Stack(
        children: [
          const BackgroundGradient(),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: PrimaryAppBar(title: 'Gerenciar Acesso'),
                  body: Container(
                    padding: EdgeInsets.all(16),
                    child: Builder(
                      builder: (_) {
                        if (state is SettingsSuccess) {
                          return _SuccessContent(
                            timeline: state.timeLine!,
                            usernameController: usernameController,
                            state: state,
                          );
                        }

                        if (state is SettingsLoading) {
                          return _LoadingContent();
                        }

                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    final surface = context.palette.surface;
    BoxDecoration deco() => BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.input),
        );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: 36,
              decoration: deco(),
            ),
          ),
          SizedBox(height: 16),
          LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: kToolbarHeight,
              decoration: deco(),
            ),
          ),
          SizedBox(height: 12),
          LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              decoration: deco(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.state,
    required this.timeline,
    required this.usernameController,
  });

  final TimeLine timeline;
  final TextEditingController usernameController;
  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quem tem acesso', style: textTheme.headlineSmall),
        kSpacerHeight16,
        ListView.builder(
          shrinkWrap: true,
          itemCount: timeline.emailsUserFirst(state.email!).length,
          itemBuilder: (context, index) {
            final item = timeline.emailsUserFirst(state.email!)[index];
            final isOwner = item == state.timeLine?.owner;
            final isSelf = item == state.email;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppRadii.input),
                border: Border.all(color: palette.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOwner ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                      size: 20,
                      color: palette.primary,
                    ),
                  ),
                  kSpacerWidth12,
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOwner || isSelf)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        isOwner ? 'Admin' : 'Você',
                        style: textTheme.bodySmall,
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => context.read<SettingsBloc>().add(DeleteEmailEvent(email: item)),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline_rounded, color: palette.danger),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        Spacer(flex: 20),
        LoginTextField(
          startIcon: Icons.person_add_alt_1,
          endIcon: Icons.send,
          endIconPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.read<SettingsBloc>().add(AddEmailEvent(email: usernameController.text));
          },
          hint: 'exemplo@email.com',
          controller: usernameController,
        ),
        Spacer()
      ],
    );
  }
}
