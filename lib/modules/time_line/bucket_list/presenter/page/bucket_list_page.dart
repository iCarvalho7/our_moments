import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_button.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

import '../../domain/entity/bucket_item.dart';
import '../bloc/bucket_list_bloc.dart';

/// Couple-only bucket list ("Sonhos do casal"). Items live in the
/// `time_line/{id}/bucket_list` subcollection and sync in real time.
class BucketListPage extends StatelessWidget {
  const BucketListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timelineId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return BlocProvider<BucketListBloc>(
      create: (_) =>
          getIt<BucketListBloc>()..add(BucketListStarted(timelineId: timelineId)),
      child: const _BucketListView(),
    );
  }
}

class _BucketListView extends StatelessWidget {
  const _BucketListView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PrimaryAppBar(title: 'Sonhos do casal'),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddSheet(context),
            child: const Icon(Icons.add_rounded),
          ),
          body: BlocBuilder<BucketListBloc, BucketListState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.items.isEmpty) {
                return _EmptyState(onAdd: () => _openAddSheet(context));
              }
              return _BucketListBody(state: state);
            },
          ),
        ),
      ],
    );
  }

  void _openAddSheet(BuildContext context) {
    final bloc = context.read<BucketListBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddBucketItemSheet(
        onSubmit: (title, category, notes) {
          bloc.add(BucketListItemAdded(title: title, category: category, notes: notes));
        },
      ),
    );
  }
}

class _BucketListBody extends StatelessWidget {
  const _BucketListBody({required this.state});

  final BucketListState state;

  @override
  Widget build(BuildContext context) {
    final pending = state.pending;
    final accomplished = state.accomplished;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (pending.isNotEmpty) ...[
          _SectionLabel(label: 'A realizar', count: pending.length),
          ...pending.map((item) => _BucketTile(item: item)),
        ],
        if (accomplished.isNotEmpty) ...[
          kSpacerHeight16,
          _SectionLabel(label: 'Realizados', count: accomplished.length),
          ...accomplished.map((item) => _BucketTile(item: item)),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          kSpacerWidth8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: palette.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BucketTile extends StatelessWidget {
  const _BucketTile({required this.item});

  final BucketItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.read<BucketListBloc>();

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => bloc.add(BucketListItemRemoved(item.id)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: palette.danger.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Icon(Icons.delete_outline_rounded, color: palette.danger),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: palette.outline),
        ),
        child: Row(
          children: [
            Checkbox(
              value: item.done,
              onChanged: (value) =>
                  bloc.add(BucketListItemToggled(id: item.id, done: value ?? false)),
            ),
            kSpacerWidth8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: textTheme.bodyLarge?.copyWith(
                      decoration: item.done ? TextDecoration.lineThrough : null,
                      color: item.done ? palette.onSurfaceMuted : palette.onSurface,
                    ),
                  ),
                  if (item.category != null && item.category!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.category!,
                        style: textTheme.bodySmall?.copyWith(color: palette.primary),
                      ),
                    ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.notes!,
                        style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 48, color: palette.onSurfaceMuted),
            kSpacerHeight16,
            Text('Nenhum sonho ainda', style: textTheme.titleMedium),
            kSpacerHeight8,
            Text(
              'Adicione os sonhos que vocês querem realizar juntos.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
            kSpacerHeight24,
            PrimaryButton(label: 'Adicionar sonho', onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}

class _AddBucketItemSheet extends StatefulWidget {
  const _AddBucketItemSheet({required this.onSubmit});

  final void Function(String title, String? category, String? notes) onSubmit;

  @override
  State<_AddBucketItemSheet> createState() => _AddBucketItemSheetState();
}

class _AddBucketItemSheetState extends State<_AddBucketItemSheet> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    widget.onSubmit(
      title,
      _categoryController.text.trim(),
      _notesController.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Novo sonho', style: textTheme.headlineSmall),
            kSpacerHeight16,
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'O que vocês querem realizar?',
                prefixIcon: Icon(Icons.star_outline_rounded),
              ),
            ),
            kSpacerHeight12,
            TextField(
              controller: _categoryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Categoria (opcional)',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
            ),
            kSpacerHeight12,
            TextField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            kSpacerHeight16,
            PrimaryButton(label: 'Adicionar', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
