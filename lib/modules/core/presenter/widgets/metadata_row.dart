import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// A compact "icon · label · value · chevron" row, tappable, used to surface a
/// piece of moment metadata (when / where / voice note) that opens a picker.
///
/// Several rows are meant to be stacked inside a single [MetadataCard].
class MetadataRow extends StatelessWidget {
  const MetadataRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.active = false,
    this.trailing,
    this.showDivider = true,
  });

  /// Leading glyph.
  final IconData icon;

  /// Fixed descriptor (e.g. "Quando").
  final String label;

  /// Current value or placeholder (e.g. "Hoje, 14:30" / "Adicionar").
  final String value;

  /// Whether the row has a meaningful value (drives accent coloring).
  final bool active;

  final VoidCallback? onTap;

  /// Replaces the trailing chevron when provided (e.g. a custom action).
  final Widget? trailing;

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.input),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: active ? palette.primarySoft : palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: active ? palette.primary : palette.onSurfaceMuted,
                  ),
                ),
                kSpacerWidth12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: active ? palette.onSurface : palette.onSurfaceMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                kSpacerWidth8,
                trailing ??
                    Icon(Icons.chevron_right_rounded, color: palette.onSurfaceMuted),
              ],
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 12),
                child: Divider(height: 1, color: palette.outline),
              ),
          ],
        ),
      ),
    );
  }
}

/// A rounded surface that groups several [MetadataRow]s together.
class MetadataCard extends StatelessWidget {
  const MetadataCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.outline),
      ),
      child: Column(children: children),
    );
  }
}
