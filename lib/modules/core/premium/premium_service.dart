import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/premium/domain/repository/purchase_repository.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/user/domain/entity/user_premium.dart';

import 'premium_feature.dart';

/// Centralizes the whole freemium rule set in one place.
///
/// There are two entitlement sources combined into an effective [PremiumTier]:
/// the shared [TimeLine] (the couple's, unlocks everything) and the individual
/// [UserPremium] (the user's, unlocks the individual features). [TimeLineBloc]
/// binds both on init/reload so the singleton always reflects the current
/// session. Every gate — UI or use case — must consult this service, so
/// changing a free limit means touching a single file.
@lazySingleton
class PremiumService {
  PremiumService(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  TimeLine? _timeLine;
  UserPremium? _user;

  /// Binds the active timeline. Called by `TimeLineBloc` on init/reload.
  void bind(TimeLine timeLine) => _timeLine = timeLine;

  /// The currently bound timeline, if any. Used by the paywall flow to know
  /// which couple's doc to mirror the purchased entitlement onto.
  TimeLine? get boundTimeLine => _timeLine;

  /// Binds the active user's premium entitlement. Called by `TimeLineBloc`
  /// alongside [bind] (null when there is no logged-in user / no doc).
  void bindUser(UserPremium? user) => _user = user;

  /// The currently bound user entitlement, if any. Used by the paywall flow to
  /// know which user's doc to mirror an individual purchase onto.
  UserPremium? get boundUser => _user;

  /// Effective tier: couple if the timeline is premium, else individual if the
  /// user is premium, else free. Couple is a superset of individual.
  /// In debug builds all features are unlocked for testing.
  PremiumTier get effectiveTier {
    if (kDebugMode) return PremiumTier.couple;
    if (_timeLine?.isActivePremium == true) return PremiumTier.couple;
    if (_user?.isActivePremium == true) return PremiumTier.individual;
    return PremiumTier.free;
  }

  /// Whether [feature] is unlocked for the current effective tier.
  bool can(PremiumFeature feature) => effectiveTier.covers(feature.minTier);

  /// Effective premium status (any paid tier). Kept for compatibility.
  bool get isPremium => effectiveTier != PremiumTier.free;

  /// Free tier allows this many photos/videos per moment.
  int get freePhotosPerMoment => 3;

  /// Allowed media per moment for the current tier (premium = effectively ∞).
  int get maxPhotosPerMoment =>
      can(PremiumFeature.unlimitedPhotos) ? 1 << 30 : freePhotosPerMoment;

  /// Free tier exposes this many accent colors in Settings.
  int get freeThemeCount => 3;

  /// Whether the store SDK can be used on this build (mobile + configured).
  bool get isStoreAvailable => _purchaseRepository.isStoreAvailable;
}
