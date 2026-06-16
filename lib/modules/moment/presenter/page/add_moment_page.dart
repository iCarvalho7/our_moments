import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presenter/widgets/floating_cta_bar.dart';
import '../../../core/presenter/widgets/overlay_sheet.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import 'share_moment_page.dart';
import '../../interactions/presenter/widget/interactions_section.dart';
import '../widget/history_container_loading.dart';
import '../widget/moment_form_section_loading.dart';
import '../widget/moment_meta_rows.dart';
import '../widget/moment_photo_hero.dart';
import '../widget/moment_type_selector.dart';

class AddOrEditMomentPage extends StatelessWidget {
  const AddOrEditMomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accentColor = ModalRoute.of(context)?.settings.arguments as int?;
    return AccentScope(
      accentColor: accentColor,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: _CircleIconButton(
            icon: CupertinoIcons.arrow_left,
            onTap: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
              buildWhen: (p, c) => p.moment.isEditing != c.moment.isEditing,
              builder: (context, state) {
                if (!state.moment.isEditing) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CircleIconButton(
                    icon: Icons.ios_share_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShareMomentPage(moment: state.moment),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
          builder: (context, state) {
            if (state is AddOrEditMomentStateLoading) {
              return _buildLoadingState();
            }
            return _buildPage(state, context);
          },
        ),
      ),
    );
  }

  Widget _buildPage(AddOrEditMomentState state, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MomentPhotoHero(),
                OverlaySheet(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MomentTypeSelector(),
                      kSpacerHeight24,
                      const _TitleField(),
                      kSpacerHeight8,
                      const _BodyField(),
                      kSpacerHeight24,
                      const MomentMetaRows(),
                      if (state.moment.isEditing) ...[
                        kSpacerHeight24,
                        Text(
                          'Reações e comentários',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        kSpacerHeight8,
                        InteractionsSection(momentId: state.moment.id),
                      ],
                    ],
                  ),
                ),
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

/// Translucent circular button used over the hero photo (back / share).
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

/// Large heading-style title field that reads like writing a memory's name.
class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      buildWhen: (p, c) => false, // keep TextFormField's own state
      builder: (context, state) {
        return TextFormField(
          initialValue: state.moment.title,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.headlineMedium,
          cursorColor: palette.primary,
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            hintText: 'Dê um título a esse momento',
            hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: palette.onSurfaceMuted,
                ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (title) => context
              .read<AddOrEditMomentBloc>()
              .add(AddOrEditMomentEventTypeTitle(title: title)),
        );
      },
    );
  }
}

/// Multiline description field.
class _BodyField extends StatelessWidget {
  const _BodyField();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      buildWhen: (p, c) => false,
      builder: (context, state) {
        return TextFormField(
          initialValue: state.moment.body,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.bodyLarge,
          cursorColor: palette.primary,
          decoration: InputDecoration(
            filled: false,
            isDense: true,
            hintText: 'Conte como foi esse momento…',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.onSurfaceMuted,
                ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (body) => context
              .read<AddOrEditMomentBloc>()
              .add(AddOrEditMomentEvenTypeBodyText(bodyText: body)),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        final enabled = state.moment.isAllFieldsFilled;
        return FloatingCtaBar(
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
