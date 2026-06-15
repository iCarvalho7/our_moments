import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/reaction.dart';
import '../bloc/interactions_bloc.dart';

class InteractionsSection extends StatelessWidget {
  final String momentId;

  const InteractionsSection({super.key, required this.momentId});

  static const List<String> _emojis = ['❤️', '😍', '😂', '🥹', '👏', '🔥'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InteractionsBloc>(
      create: (_) =>
          getIt<InteractionsBloc>()..add(InteractionsStarted(momentId: momentId)),
      child: const _InteractionsView(),
    );
  }

  static List<String> get emojis => _emojis;
}

class _InteractionsView extends StatelessWidget {
  const _InteractionsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reações', style: theme.textTheme.titleMedium),
                kSpacerHeight16Half,
                const _ReactionPicker(),
                kSpacerHeight16Half,
                const _ReactionsList(),
              ],
            ),
          ),
          kSpacerHeight16,
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comentários', style: theme.textTheme.titleMedium),
                kSpacerHeight16Half,
                const _CommentField(),
                kSpacerHeight16Half,
                const _CommentsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const kSpacerHeight16Half = SizedBox(height: 12);

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}

class _ReactionPicker extends StatelessWidget {
  const _ReactionPicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: InteractionsSection.emojis.map((emoji) {
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => context
              .read<InteractionsBloc>()
              .add(InteractionsReactionAdded(emoji)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        );
      }).toList(),
    );
  }
}

class _ReactionsList extends StatelessWidget {
  const _ReactionsList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<InteractionsBloc, InteractionsState>(
      buildWhen: (previous, current) =>
          previous.reactions != current.reactions ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        if (state.reactions.isEmpty) {
          return Text(
            'Seja o primeiro a reagir.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        final grouped = <String, List<Reaction>>{};
        for (final reaction in state.reactions) {
          grouped.putIfAbsent(reaction.emoji, () => []).add(reaction);
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: grouped.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.value.length}',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CommentField extends StatefulWidget {
  const _CommentField();

  @override
  State<_CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<_CommentField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    context.read<InteractionsBloc>().add(InteractionsCommentAdded(text));
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            minLines: 1,
            maxLines: 3,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Escreva um comentário...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _submit(context),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _submit(context),
          color: theme.colorScheme.primary,
          icon: const Icon(Icons.send_rounded),
        ),
      ],
    );
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<InteractionsBloc, InteractionsState>(
      buildWhen: (previous, current) =>
          previous.comments != current.comments ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        if (state.comments.isEmpty) {
          return Text(
            'Ainda não há comentários.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Column(
          children: state.comments
              .map((comment) => _CommentTile(comment: comment))
              .toList(),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.author,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(comment.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
