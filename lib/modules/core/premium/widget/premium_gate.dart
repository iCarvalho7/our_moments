import 'package:flutter/material.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/premium/presenter/page/paywall_page.dart';

import '../../utils/theme/app_theme.dart';
import '../premium_feature.dart';
import '../premium_service.dart';

/// Shows [child] when [feature] is unlocked; otherwise renders a locked
/// affordance (a padlock badge over a dimmed child) whose tap opens the
/// paywall.
class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.feature,
    required this.child,
    this.locked,
  });

  /// The feature this gate guards.
  final PremiumFeature feature;

  /// Rendered when the feature is unlocked.
  final Widget child;

  /// Optional custom locked presentation. When null, [child] is dimmed and a
  /// padlock badge is overlaid; tapping anywhere shows the premium CTA.
  final Widget? locked;

  @override
  Widget build(BuildContext context) {
    if (getIt<PremiumService>().can(feature)) return child;

    if (locked != null) {
      return GestureDetector(
        onTap: () => showPremiumPlaceholder(context, feature),
        child: locked,
      );
    }

    final palette = context.palette;
    return GestureDetector(
      onTap: () => showPremiumPlaceholder(context, feature),
      child: Stack(
        children: [
          Opacity(opacity: 0.45, child: IgnorePointer(child: child)),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.soft(context),
                ),
                child: Icon(Icons.lock_rounded, size: 20, color: palette.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the paywall for a locked premium [feature].
///
/// Returns `true` when the user becomes premium during the flow, so callers can
/// refresh the timeline (re-binding [PremiumService]). Kept named
/// `showPremiumPlaceholder` to avoid churning every existing call site.
Future<bool> showPremiumPlaceholder(
  BuildContext context,
  PremiumFeature feature,
) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => PaywallPage(highlightFeature: feature),
    ),
  );
  return result ?? false;
}
