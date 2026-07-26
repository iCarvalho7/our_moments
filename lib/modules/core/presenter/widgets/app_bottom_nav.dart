import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// A single entry in [AppBottomNav].
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.selected = false,
    this.navKey,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Renders as the elevated accent diamond action that juts out of the bar.
  final bool primary;

  /// Highlights the item as the current selection.
  final bool selected;

  /// Optional key applied to the rendered nav button (used by E2E tests).
  final Key? navKey;
}

/// Floating pill-shaped bottom navigation with a highlighted central action,
/// matching the modern reference design. Honors the bottom safe area.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.items});

  final List<AppNavItem> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        boxShadow: AppShadows.lift(context),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        left: 8,
        right: 8,
      ),
      child: SizedBox(
        height: 68,
        child: Row(
          children: items
              .map((item) => Expanded(child: _NavButton(key: item.navKey, item: item)))
              .toList(),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({super.key, required this.item});

  final AppNavItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (item.primary) {
      final selected = item.selected;
      return GestureDetector(
        onTap: item.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 72,
          height: 68,
          // Diamond and label are pushed up (Transform.translate paints outside
          // the layout box) so the action juts out above the bar without
          // triggering a layout overflow.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -14),
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: selected ? Border.all(color: palette.onPrimary, width: 2.5) : null,
                      boxShadow: [
                        BoxShadow(
                          color: palette.primary.withValues(alpha: 0.40),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: Icon(item.icon, color: palette.onPrimary, size: 26),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -8),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final color = item.selected ? palette.primary : palette.onSurfaceMuted;
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: item.selected ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
