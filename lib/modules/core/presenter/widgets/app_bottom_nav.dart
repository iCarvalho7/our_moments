import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// A single entry in [AppBottomNav].
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.navKey,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Renders as the elevated accent "+" action in the middle of the bar.
  final bool primary;

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
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: palette.outline),
          boxShadow: AppShadows.soft(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) => _NavButton(key: item.navKey, item: item)).toList(),
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
      return GestureDetector(
        onTap: item.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
                boxShadow: AppShadows.soft(context),
              ),
              child: Icon(item.icon, color: palette.onPrimary, size: 28),
            ),
            const SizedBox(height: 3 + 10), // mirrors gap + label height of regular items
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: palette.onSurfaceMuted, size: 24),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
