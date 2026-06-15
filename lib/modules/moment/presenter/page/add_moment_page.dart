import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import 'share_moment_page.dart';
import '../../interactions/presenter/widget/interactions_section.dart';
import '../widget/date_time_section.dart';
import '../widget/description_section.dart';
import '../widget/location_section.dart';
import '../widget/history_container_loading.dart';
import '../../../photos/presentation/widget/photos_container.dart';
import '../widget/moment_form_section_loading.dart';
import '../widget/select_type_toggle.dart';
import '../widget/tile_section.dart';

class AddOrEditMomentPage extends StatelessWidget {
  const AddOrEditMomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text('Novo momento'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.arrow_left),
          ),
          actions: [
            BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
              builder: (context, state) {
                if (!state.moment.isEditing) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.ios_share_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ShareMomentPage(moment: state.moment)),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
          builder: (context, state) {
            return _buildPage(state, context);
          },
        ),
      ),
    );
  }

  Widget _buildPage(AddOrEditMomentState state, BuildContext context) {
    if (state is AddOrEditMomentStateLoading) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Como foi esse momento?'),
                const SelectTypeToggle(),
                const _SectionLabel('Fotos e vídeos'),
                const PhotosContainer(),
                const _SectionLabel('Quando aconteceu'),
                const DateTimeSection(),
                const _SectionLabel('Onde foi'),
                const LocationSection(),
                const _SectionLabel('Título'),
                const TitleSection(),
                const _SectionLabel('Descrição'),
                const DescriptionSection(),
                if (state.moment.isEditing) ...[
                  const _SectionLabel('Reações e comentários'),
                  InteractionsSection(momentId: state.moment.id),
                ],
              ],
            ),
          ),
        ),
        const _SubmitButton(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(10.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryContainerLoading(),
          MomentFormSectionLoading(),
        ],
      ),
    );
  }

}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: context.palette.onSurfaceMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        final enabled = state.moment.isAllFieldsFilled;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: palette.background,
            border: Border(top: BorderSide(color: palette.outline)),
          ),
          child: ElevatedButton(
            onPressed: enabled
                ? () => context
                    .read<AddOrEditMomentBloc>()
                    .add(const AddOrEditMomentEventCreateOrUpdateMoment())
                : null,
            child: Text(state.moment.isEditing ? 'Salvar edição' : 'Registrar eternamente'),
          ),
        );
      },
    );
  }
}
