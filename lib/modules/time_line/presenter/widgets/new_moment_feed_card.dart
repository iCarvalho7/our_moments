import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_card.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_network_image.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/privacy_badge.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/interactions/presenter/bloc/interactions_bloc.dart';
import 'package:nossos_momentos/modules/moment/interactions/presenter/widget/interactions_section.dart';
import 'package:nossos_momentos/modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';

import '../../domain/entity/time_line.dart';
import '../bloc/new_feed_cubit.dart';

/// A single moment rendered as a social-feed card. Expects an
/// [InteractionsBloc] to already be provided above it in the tree (the feed
/// page provisions one per card, keyed by moment id).
class NewMomentFeedCard extends StatelessWidget {
  const NewMomentFeedCard({
    super.key,
    required this.moment,
    required this.timeline,
    required this.currentUserEmail,
    this.onWillNavigate,
  });

  final Moment moment;
  final TimeLine timeline;
  final String currentUserEmail;
  final VoidCallback? onWillNavigate;

  Color _accent(BuildContext context) => timeline.accentColor != null
      ? Color(timeline.accentColor!)
      : context.palette.primary;

  void _openMoment(BuildContext context) {
    onWillNavigate?.call();
    final feedCubit = context.read<NewFeedCubit>();
    context.read<AddOrEditMomentBloc>().add(SetupEditMomentEvent(moment: moment));
    Navigator.pushNamed(
      context,
      AppRoute.addMoment.tag,
      arguments: (
        accentColor: timeline.accentColor,
        endDate: timeline.enforceEndDate ? timeline.relationshipEndDate : null,
      ),
    ).then((_) => feedCubit.load());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final accent = _accent(context);
    final photos = moment.uploadedImgList;
    final body = moment.body;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => _openMoment(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FeedCardHeader(
            moment: moment,
            timeline: timeline,
            currentUserEmail: currentUserEmail,
            accent: accent,
          ),
          if (photos.isNotEmpty)
            // AppCard does not clip its children, so the media itself must be
            // clipped to the card's rounded corners.
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
              child: _PhotoArea(photos: photos),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TypeBadge(moment: moment),
                    if (moment.isPrivate) ...[
                      kSpacerWidth8,
                      const PrivacyBadge(memberCount: 1, isPrivate: true),
                    ],
                  ],
                ),
                kSpacerHeight8,
                Text(
                  moment.title.isNotEmpty ? moment.title : 'Sem título',
                  style: textTheme.titleLarge,
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: palette.onSurfaceMuted),
                  ),
                ],
                if (moment.hasLocation) ...[
                  const SizedBox(height: 10),
                  _LocationRow(moment: moment),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          _InteractionBar(moment: moment, accent: accent),
        ],
      ),
    );
  }
}

/// Top row: timeline pill + author chip + relative date.
class _FeedCardHeader extends StatelessWidget {
  const _FeedCardHeader({
    required this.moment,
    required this.timeline,
    required this.currentUserEmail,
    required this.accent,
  });

  final Moment moment;
  final TimeLine timeline;
  final String currentUserEmail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Flexible(
            child: _TimelineBadge(timeline: timeline, accent: accent),
          ),
          kSpacerWidth8,
          _AuthorChip(
            moment: moment,
            timeline: timeline,
            currentUserEmail: currentUserEmail,
            accent: accent,
          ),
          const Spacer(),
          _DateLabel(dateTime: moment.dateTime),
        ],
      ),
    );
  }
}

class _TimelineBadge extends StatelessWidget {
  const _TimelineBadge({required this.timeline, required this.accent});

  final TimeLine timeline;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = timeline.name.isNotEmpty ? timeline.name : 'História';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AuthorChip extends StatelessWidget {
  const _AuthorChip({
    required this.moment,
    required this.timeline,
    required this.currentUserEmail,
    required this.accent,
  });

  final Moment moment;
  final TimeLine timeline;
  final String currentUserEmail;
  final Color accent;

  String _label() {
    if (moment.author.isEmpty) return 'Desconhecido';
    if (moment.author == currentUserEmail) return 'Você';
    final nickname = timeline.nicknames[moment.author];
    if (nickname != null && nickname.isNotEmpty) return nickname;
    final local = moment.author.split('@').first;
    if (local.isEmpty) return moment.author;
    return '${local[0].toUpperCase()}${local.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final label = _label();
    final initial = label.isNotEmpty ? label[0].toUpperCase() : '?';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.dateTime});

  final DateTime dateTime;

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    return DateFormat('d MMM', 'pt_BR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Text(
      _label(),
      style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
    );
  }
}

/// Swipeable photo gallery with page dots.
class _PhotoArea extends StatefulWidget {
  const _PhotoArea({required this.photos});

  final List<String> photos;

  @override
  State<_PhotoArea> createState() => _PhotoAreaState();
}

class _PhotoAreaState extends State<_PhotoArea> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => AppNetworkImage(
              url: widget.photos[i],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 240,
            ),
          ),
          if (widget.photos.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: _PageDots(count: widget.photos.length, active: _index),
            ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: selected ? 8 : 6,
          height: selected ? 8 : 6,
          decoration: BoxDecoration(
            // Dots sit over media, so a fixed light tone stays readable.
            color: Colors.white.withValues(alpha: selected ? 0.95 : 0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = moment.type.colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(moment.type.icon, size: 14, color: colors.accent),
          const SizedBox(width: 6),
          Text(
            moment.type.label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onBg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final label =
        moment.locationName.isNotEmpty ? moment.locationName : 'Localização';
    return Row(
      children: [
        Icon(Icons.place_outlined, size: 15, color: palette.onSurfaceMuted),
        kSpacerWidth8,
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
          ),
        ),
      ],
    );
  }
}

/// Bottom bar: quick reactions + comment count + share.
class _InteractionBar extends StatelessWidget {
  const _InteractionBar({required this.moment, required this.accent});

  final Moment moment;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
      child: Row(
        children: [
          // Expands to fill the leftover space, pushing the comment/share
          // controls to the right (Spacer-like) while staying scrollable so a
          // narrow card never overflows.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _QuickReactions(accent: accent),
            ),
          ),
          kSpacerWidth8,
          _CommentCountChip(moment: moment),
          _ShareButton(moment: moment),
        ],
      ),
    );
  }
}

class _QuickReactions extends StatelessWidget {
  const _QuickReactions({required this.accent});

  final Color accent;

  void _toggle(BuildContext context, InteractionsState state, String emoji) {
    final bloc = context.read<InteractionsBloc>();
    final mine = state.reactions
        .where((r) => r.author == state.currentUser && r.emoji == emoji)
        .toList();
    if (mine.isNotEmpty) {
      bloc.add(InteractionsReactionRemoved(mine.first.id));
    } else {
      bloc.add(InteractionsReactionAdded(emoji));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<InteractionsBloc, InteractionsState>(
      buildWhen: (previous, current) =>
          previous.reactions != current.reactions ||
          previous.currentUser != current.currentUser,
      builder: (context, state) {
        final myEmojis = state.reactions
            .where((r) => r.author == state.currentUser)
            .map((r) => r.emoji)
            .toSet();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: InteractionsSection.emojis.map((emoji) {
            final selected = myEmojis.contains(emoji);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                onTap: () => _toggle(context, state, emoji),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected ? palette.primarySoft : palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CommentCountChip extends StatelessWidget {
  const _CommentCountChip({required this.moment});

  final Moment moment;

  void _openComments(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (sheetContext, scrollController) {
          final palette = sheetContext.palette;
          return Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                    ),
                    // A fresh InteractionsSection provisions its own bloc — it
                    // does not reuse the card's bloc.
                    child: InteractionsSection(momentId: moment.id),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return BlocBuilder<InteractionsBloc, InteractionsState>(
      buildWhen: (previous, current) => previous.comments != current.comments,
      builder: (context, state) {
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: () => _openComments(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: palette.onSurfaceMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  '${state.comments.length}',
                  style: textTheme.bodySmall
                      ?.copyWith(color: palette.onSurfaceMuted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      tooltip: 'Compartilhar',
      icon: Icon(Icons.share_outlined, size: 20, color: palette.onSurfaceMuted),
      onPressed: () => Navigator.of(context).pushNamed(
        AppRoute.shareMoment.tag,
        arguments: moment,
      ),
    );
  }
}
