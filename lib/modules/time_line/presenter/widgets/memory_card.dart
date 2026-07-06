import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/domain/entities/moment.dart';

/// Immersive "memory" card: the moment's first photo fills the card with a
/// gradient scrim and the title/date overlaid. Falls back to a colored
/// gradient (by moment type) when there is no photo or it fails to load.
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.moment,
    this.onFavoriteToggle,
    this.nicknames = const {},
    this.currentUserEmail = '',
  });

  final Moment moment;
  final VoidCallback? onFavoriteToggle;
  final Map<String, String> nicknames;
  final String currentUserEmail;

  String _resolveAuthorName() {
    if (moment.author.isEmpty) return '';
    if (moment.author == currentUserEmail) return 'Você';
    return nicknames[moment.author] ??
        moment.author.split('@').first.replaceAll('.', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = moment.type.colors(context);
    final radius = BorderRadius.circular(AppRadii.card);
    final heroUrl = moment.downloadUrlList.isNotEmpty ? moment.downloadUrlList.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 380,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.soft(context),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (heroUrl != null)
              CachedNetworkImage(
                imageUrl: heroUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _GradientBackground(colors: colors),
                errorWidget: (_, __, ___) =>
                    _GradientBackground(colors: colors, icon: moment.type.icon),
              )
            else
              _GradientBackground(colors: colors, icon: moment.type.icon),
            const _BottomScrim(),
            Positioned(
              top: 16,
              left: 16,
              child: _TypeChip(
                icon: moment.type.icon,
                label: moment.type.label,
                accent: colors.accent,
              ),
            ),
            if (onFavoriteToggle != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: const CircleBorder(),
                  child: IconButton(
                    iconSize: 22,
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      moment.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: moment.isFavorite ? const Color(0xFFFF6B7A) : Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moment.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        moment.dateTimeFormatted,
                        style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                      if (moment.hasAudio) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.mic_rounded, size: 14, color: Colors.white70),
                      ],
                    ],
                  ),
                  if (moment.locationName.isNotEmpty || moment.hasLocation) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            moment.locationName.isNotEmpty ? moment.locationName : 'Local marcado',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_resolveAuthorName() case final String authorName
                      when authorName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.colors, this.icon});

  final MomentColors colors;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.bg, colors.accent],
        ),
      ),
      child: icon == null
          ? null
          : Center(
              child: Icon(icon, size: 72, color: Colors.white.withValues(alpha: 0.85)),
            ),
    );
  }
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
          stops: [0.45, 1.0],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.icon, required this.label, required this.accent});

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
