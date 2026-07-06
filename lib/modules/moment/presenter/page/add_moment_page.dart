import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/floating_cta_bar.dart';
import '../../../core/presenter/widgets/loading_effect.dart';
import '../../../core/presenter/widgets/overlay_sheet.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../../interactions/presenter/widget/interactions_section.dart';
import '../widget/history_container_loading.dart';
import '../widget/moment_form_section_loading.dart';
import '../widget/moment_meta_rows.dart';
import '../widget/moment_photo_hero.dart';
import '../widget/moment_type_selector.dart';

typedef _MomentPageArgs = ({int? accentColor, DateTime? endDate});

class AddOrEditMomentPage extends StatelessWidget {
  const AddOrEditMomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final int? accentColor;
    final DateTime? endDate;
    if (rawArgs is _MomentPageArgs) {
      accentColor = rawArgs.accentColor;
      endDate = rawArgs.endDate;
    } else {
      accentColor = rawArgs as int?;
      endDate = null;
    }
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
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CircleIconButton(
                      icon: CupertinoIcons.delete,
                      onTap: () => _confirmDelete(context),
                    ),
                    const SizedBox(width: 8),
                    _CircleIconButton(
                      icon: Icons.ios_share_rounded,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoute.shareMoment.tag,
                        arguments: state.moment,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<AddOrEditMomentBloc, AddOrEditMomentState>(
          listenWhen: (prev, c) =>
              c is AddOrEditMomentStateError ||
              c is AddOrEditMomentStateDeleted ||
              (prev is AddOrEditMomentStateLoading && c is AddOrEditMomentStateUpdate),
          listener: (context, state) {
            if (state is AddOrEditMomentStateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Não foi possível salvar o momento. Verifique sua conexão e tente novamente.'),
                ),
              );
              return;
            }
            Navigator.of(context).pop(true);
          },
          builder: (context, state) {
            if (state is AddOrEditMomentStateLoading) {
              return _buildLoadingState(context);
            }
            return _buildPage(state, context, endDate);
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deletar momento'),
        content: const Text('Tem certeza que deseja deletar este momento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Deletar',
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<AddOrEditMomentBloc>().add(const AddOrEditMomentEventDeleteMoment());
      }
    });
  }

  Widget _buildPage(AddOrEditMomentState state, BuildContext context, DateTime? endDate) {
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
                      if (endDate != null) _EndDateBanner(endDate: endDate),
                      const MomentTypeSelector(),
                      kSpacerHeight24,
                      const _TitleField(),
                      kSpacerHeight8,
                      const _BodyField(),
                      kSpacerHeight24,
                      MomentMetaRows(lastDate: endDate),
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

  Widget _buildLoadingState(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero shimmer — matches MomentPhotoHero's default height (360px),
        // extends behind the transparent app bar (extendBodyBehindAppBar: true).
        LoadingEffect(
          child: Container(
            height: 360,
            width: double.infinity,
            color: palette.surfaceAlt,
          ),
        ),
        // Content sheet — mirrors OverlaySheet: -24px overlap, rounded top, same padding.
        Transform.translate(
          offset: const Offset(0, -24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.sheet),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HistoryContainerLoading(),
                MomentFormSectionLoading(),
              ],
            ),
          ),
        ),
      ],
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

/// Shown at the top of the form when the timeline has an end date. Makes the
/// date constraint visible so users understand why the calendar is limited.
class _EndDateBanner extends StatelessWidget {
  const _EndDateBanner({required this.endDate});

  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_outlined, size: 18, color: palette.onSurfaceMuted),
          kSpacerWidth8,
          Expanded(
            child: Text(
              'Linha do tempo encerrada em ${DateFormat('dd/MM/yyyy').format(endDate)}. '
              'Momentos devem ter data até esse dia.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        final bloc = context.read<AddOrEditMomentBloc>();
        final enabled = state.moment.isAllFieldsFilled &&
            (!state.moment.isEditing || bloc.isDirty);
        return FloatingCtaBar(
          child: ElevatedButton(
            onPressed: enabled
                ? () => bloc.add(const AddOrEditMomentEventCreateOrUpdateMoment())
                : null,
            child: Text(state.moment.isEditing ? 'Salvar edição' : 'Registrar eternamente'),
          ),
        );
      },
    );
  }
}
