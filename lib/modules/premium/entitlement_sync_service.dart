import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../core/premium/premium_feature.dart';
import '../core/premium/premium_service.dart';
import '../core/use_case/use_case.dart';
import 'domain/entity/entitlement_status.dart';
import 'domain/use_case/get_entitlement_status_use_case.dart';
import 'domain/use_case/sync_entitlement_use_case.dart';
import 'domain/use_case/sync_user_entitlement_use_case.dart';

/// Centralizes the entitlement → Firestore/[PremiumService] routing so it can be
/// driven from both the purchase flow (the bloc) and the global RevenueCat
/// `addCustomerInfoUpdateListener` (renewals, expirations, Customer Center
/// changes). Does NOT emit UI state — it only mirrors and re-binds.
@lazySingleton
class EntitlementSyncService {
  final SyncEntitlementUseCase _syncEntitlementUseCase;
  final SyncUserEntitlementUseCase _syncUserEntitlementUseCase;
  final GetEntitlementStatusUseCase _getEntitlementStatusUseCase;
  final PremiumService _premiumService;

  EntitlementSyncService(
    this._syncEntitlementUseCase,
    this._syncUserEntitlementUseCase,
    this._getEntitlementStatusUseCase,
    this._premiumService,
  );

  /// Mirrors [status] onto the right doc by tier and re-binds [PremiumService]
  /// so gates unlock immediately.
  ///
  /// - couple → timeline doc (when one is bound) + [PremiumService.bind].
  /// - individual → user doc + [PremiumService.bindUser].
  /// - free → no-op: never downgrades Firestore here (a real downgrade is
  ///   reconciled on the next read via `premiumUntil`).
  Future<void> applyStatus(EntitlementStatus status) async {
    switch (status.tier) {
      case PremiumTier.couple:
        final timeline = _premiumService.boundTimeLine;
        if (timeline != null) {
          final sync = await _syncEntitlementUseCase.call(
            SyncEntitlementParams(timeline: timeline, status: status),
          );
          if (sync.isSuccess && sync.data != null) {
            _premiumService.bind(sync.data!);
          }
        }

      case PremiumTier.individual:
        final sync = await _syncUserEntitlementUseCase.call(
          SyncUserEntitlementParams(status: status),
        );
        if (sync.isSuccess && sync.data != null) {
          _premiumService.bindUser(sync.data!);
        }

      case PremiumTier.free:
        // No-op: do not downgrade Firestore from a transient/free read.
        break;
    }
  }

  /// Reads the live entitlement and applies it. Tolerates errors silently
  /// (best-effort sync from the global listener / startup).
  Future<void> refresh() async {
    try {
      final result = await _getEntitlementStatusUseCase.call(NoParams.instance);
      if (result.isSuccess && result.data != null) {
        await applyStatus(result.data!);
      }
    } catch (error, stack) {
      debugPrint('EntitlementSyncService.refresh failed: $error\n$stack');
    }
  }
}
