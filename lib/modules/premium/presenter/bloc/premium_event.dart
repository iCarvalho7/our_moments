part of 'premium_bloc.dart';

sealed class PremiumEvent {}

/// Fetches the current offering's plans.
class PremiumEventLoadOfferings extends PremiumEvent {}

/// Starts the purchase flow for [plan].
class PremiumEventPurchase extends PremiumEvent {
  final PremiumPlan plan;

  PremiumEventPurchase(this.plan);
}

/// Restores previous purchases.
class PremiumEventRestore extends PremiumEvent {}

/// Opens the RevenueCat-hosted paywall for the chosen [tier]'s offering.
class PremiumEventPresentPaywall extends PremiumEvent {
  final PremiumTier tier;

  PremiumEventPresentPaywall(this.tier);
}
