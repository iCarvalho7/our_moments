import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// Small "who can see this" pill that makes the app's privacy guarantee
/// visible: a lock plus a plain-language audience label. Takes primitive
/// inputs so it can sit on a feed card, a moment header, or anywhere else
/// without depending on the timeline entity.
class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({
    super.key,
    required this.memberCount,
    this.isPrivate = false,
    this.compact = false,
    this.onTap,
  });

  /// Number of people who can see this timeline (its members).
  final int memberCount;

  /// When true, this is a private moment only its author can see, regardless
  /// of how many people share the timeline.
  final bool isPrivate;

  /// Tighter styling for overlaying on a photo/card.
  final bool compact;

  final VoidCallback? onTap;

  String get _label {
    if (isPrivate) return 'Só você vê';
    return switch (memberCount) {
      <= 1 => 'Só você',
      2 => 'Só vocês dois',
      _ => '$memberCount pessoas podem ver',
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onCard = compact;
    final bg = onCard
        ? Colors.black.withValues(alpha: 0.42)
        : palette.primarySoft;
    final fg = onCard ? Colors.white : palette.primary;

    final pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrivate ? Icons.lock_rounded : Icons.lock_outline_rounded,
            size: compact ? 13 : 15,
            color: fg,
          ),
          SizedBox(width: compact ? 5 : 7),
          Text(
            _label,
            style: (compact
                    ? Theme.of(context).textTheme.labelSmall
                    : Theme.of(context).textTheme.labelMedium)
                ?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;
    return GestureDetector(onTap: onTap, child: pill);
  }
}
