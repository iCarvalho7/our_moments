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
    final timeline = ModalRoute.of(context)?.settings.arguments as TimeLine;

    return BlocProvider<SettingsBloc>(
      create: (context) => getIt<SettingsBloc>()..add(FetchEmailEvent(timeLine: timeline)),
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
                            timeline: timeline,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              LoadingEffect(
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: kToolbarHeight,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: kToolbarHeight,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12),
          LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              color: Colors.grey,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acesso:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: timeline.emailsUserFirst(state.email!).length,
          itemBuilder: (context, index) {
            final item = timeline.emailsUserFirst(state.email!)[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: AppThemes.roundedBorder.copyWith(
                border: Border.all(color: Colors.transparent),
                color: Color(0xffF8EEEE),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  if (item == state.email) ...[Icon(Icons.person_sharp)],
                  if (item == state.timeLine?.owner) ...[Icon(Icons.admin_panel_settings_outlined)],
                  Spacer(),
                  Text(item, style: Theme.of(context).textTheme.bodyMedium),
                  Spacer(),
                  if (item != state.email && item != state.timeLine?.owner) ...[
                    InkWell(
                      onTap: () => context.read<SettingsBloc>().add(DeleteEmailEvent(email: item)),
                      child: Icon(Icons.delete, color: Colors.red),
                    )
                  ],
                  SizedBox(width: 8)
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
