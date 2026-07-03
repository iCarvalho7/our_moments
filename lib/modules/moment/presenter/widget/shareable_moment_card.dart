import 'package:flutter/material.dart';
import 'package:nossos_momentos/di/injection.dart';

import '../../../core/premium/premium_feature.dart';
import '../../../core/premium/premium_service.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment.dart';

/// A polished, fixed-ratio card used to render a shareable image of a moment.
class ShareableMomentCard extends StatelessWidget {
  const ShareableMomentCard({super.key, required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final colors = moment.type.colors(context);
    final hero = moment.downloadUrlList.isNotEmpty ? moment.downloadUrlList.first : null;
    // Free tier stamps the brand watermark; premium shares clean.
    final showWatermark = !getIt<PremiumService>().can(PremiumFeature.watermarkFree);

    final meta = [
      moment.dateTimeFormatted,
      if (moment.locationName.isNotEmpty) moment.locationName,
    ].join('  ·  ');

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hero != null)
              Image.network(
                hero,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Gradient(colors: colors, icon: moment.type.icon),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _Gradient(colors: colors, icon: moment.type.icon),
              )
            else
              _Gradient(colors: colors, icon: moment.type.icon),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.4, 1.0],
                ),
              ),
            ),

            Positioned(
              top: 22,
              left: 22,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(moment.type.icon, size: 16, color: colors.accent),
                    const SizedBox(width: 6),
                    Text(
                      moment.type.label,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moment.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                  if (showWatermark) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          Strings.appName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
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

class _Gradient extends StatelessWidget {
  const _Gradient({required this.colors, required this.icon});

  final MomentColors colors;
  final IconData icon;

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
      child: Center(child: Icon(icon, size: 96, color: Colors.white.withValues(alpha: 0.85))),
    );
  }
}
