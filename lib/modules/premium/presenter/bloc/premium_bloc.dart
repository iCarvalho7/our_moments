import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/premium/premium_feature.dart';
import '../../../core/use_case/use_case.dart';
import '../../domain/entity/entitlement_status.dart';
import '../../domain/entity/premium_plan.dart';
import '../../domain/purchase_exception.dart';
import '../../domain/use_case/get_offerings_use_case.dart';
import '../../domain/use_case/present_paywall_use_case.dart';
import '../../domain/use_case/purchase_use_case.dart';
import '../../domain/use_case/restore_purchases_use_case.dart';
import '../../entitlement_sync_service.dart';

part 'premium_event.dart';
part 'premium_state.dart';

@injectable
class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final GetOfferingsUseCase _getOfferingsUseCase;
  final PurchaseUseCase _purchaseUseCase;
  final RestorePurchasesUseCase _restorePurchasesUseCase;
  final PresentPaywallUseCase _presentPaywallUseCase;
  final EntitlementSyncService _entitlementSyncService;

  PremiumBloc(
    this._getOfferingsUseCase,
    this._purchaseUseCase,
    this._restorePurchasesUseCase,
    this._presentPaywallUseCase,
    this._entitlementSyncService,
  ) : super(PremiumStateInitial()) {
    on<PremiumEventLoadOfferings>(_loadOfferings);
    on<PremiumEventPurchase>(_purchase);
    on<PremiumEventRestore>(_restore);
    on<PremiumEventPresentPaywall>(_presentPaywall);
  }

  FutureOr<void> _loadOfferings(
    PremiumEventLoadOfferings event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumStateLoading());

    final result = await _getOfferingsUseCase.call(NoParams.instance);

    if (result.isError || result.data == null) {
      emit(PremiumStateError(
        _messageFor(
          result.exception,
          fallback: 'Não foi possível carregar os planos. Tente novamente.',
        ),
      ));
      return;
    }

    if (result.data!.isEmpty) {
      emit(PremiumStateError('Nenhum plano disponível no momento.'));
      return;
    }

    emit(PremiumStateLoaded(result.data!));
  }

  FutureOr<void> _purchase(
    PremiumEventPurchase event,
    Emitter<PremiumState> emit,
  ) async {
    final plans = _currentPlans();
    emit(PremiumStatePurchasing(plans));

    final result = await _purchaseUseCase.call(event.plan);

    if (result.isError || result.data == null) {
      // A user-cancelled purchase also lands here; keep it gentle.
      emit(PremiumStateError(
        _messageFor(
          result.exception,
          fallback: 'Não foi possível concluir a compra. Tente novamente.',
        ),
        plans: plans,
      ));
      return;
    }

    await _syncAndFinish(result.data!, plans, emit);
  }

  FutureOr<void> _restore(
    PremiumEventRestore event,
    Emitter<PremiumState> emit,
  ) async {
    final plans = _currentPlans();
    emit(PremiumStatePurchasing(plans));

    final result = await _restorePurchasesUseCase.call(NoParams.instance);

    if (result.isError || result.data == null) {
      emit(PremiumStateError(
        _messageFor(
          result.exception,
          fallback: 'Não foi possível restaurar suas compras.',
        ),
        plans: plans,
      ));
      return;
    }

    if (!result.data!.isActive) {
      emit(PremiumStateError(
        'Nenhuma assinatura ativa encontrada.',
        plans: plans,
      ));
      return;
    }

    await _syncAndFinish(result.data!, plans, emit);
  }

  /// Opens the hosted paywall for [event.tier]. On an active result, mirrors it
  /// via [EntitlementSyncService] and emits success (the page pops `true`); a
  /// cancel leaves the user on the selector without a noisy error.
  FutureOr<void> _presentPaywall(
    PremiumEventPresentPaywall event,
    Emitter<PremiumState> emit,
  ) async {
    final plans = _currentPlans();
    emit(PremiumStatePurchasing(plans));

    final result = await _presentPaywallUseCase.call(event.tier);

    if (result.isError || result.data == null) {
      emit(PremiumStateError(
        _messageFor(
          result.exception,
          fallback: 'Não foi possível abrir os planos. Tente novamente.',
        ),
        plans: plans,
      ));
      return;
    }

    if (!result.data!.isActive) {
      // User closed the paywall without subscribing — back to the selector.
      emit(PremiumStateLoaded(plans));
      return;
    }

    await _syncAndFinish(result.data!, plans, emit);
  }

  /// Mirrors the entitlement onto the right doc by tier (via
  /// [EntitlementSyncService]) so gates unlock immediately, then emits success.
  /// A free/inactive status surfaces an error (nothing was bought).
  Future<void> _syncAndFinish(
    EntitlementStatus status,
    List<PremiumPlan> plans,
    Emitter<PremiumState> emit,
  ) async {
    if (status.tier == PremiumTier.free) {
      emit(PremiumStateError(
        'Nenhuma assinatura ativa encontrada.',
        plans: plans,
      ));
      return;
    }

    await _entitlementSyncService.applyStatus(status);
    emit(PremiumStateSuccess());
  }

  /// Prefers a domain-provided, user-facing message (e.g. "purchases only on
  /// mobile") over the generic [fallback].
  String _messageFor(Object? exception, {required String fallback}) {
    if (exception is PurchasesUnavailableException) return exception.message;
    return fallback;
  }

  List<PremiumPlan> _currentPlans() {
    final current = state;
    if (current is PremiumStateLoaded) return current.plans;
    if (current is PremiumStatePurchasing) return current.plans;
    if (current is PremiumStateError) return current.plans ?? const [];
    return const [];
  }
}
