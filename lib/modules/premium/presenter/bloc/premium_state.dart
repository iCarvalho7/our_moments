part of 'premium_bloc.dart';

sealed class PremiumState {}

final class PremiumStateInitial extends PremiumState {}

final class PremiumStateLoading extends PremiumState {}

final class PremiumStateLoaded extends PremiumState {
  final List<PremiumPlan> plans;

  PremiumStateLoaded(this.plans);
}

/// A purchase or restore is in flight; keeps [plans] so the list stays visible.
final class PremiumStatePurchasing extends PremiumState {
  final List<PremiumPlan> plans;

  PremiumStatePurchasing(this.plans);
}

/// Purchase/restore succeeded and the entitlement was mirrored on the timeline.
final class PremiumStateSuccess extends PremiumState {}

final class PremiumStateError extends PremiumState {
  final String message;

  /// Plans to keep on screen when the error happened mid-flow (null on the
  /// initial load failure).
  final List<PremiumPlan>? plans;

  PremiumStateError(this.message, {this.plans});
}
