/// Thrown when the store SDK isn't available on the current platform —
/// RevenueCat (`purchases_flutter`) only supports Android and iOS, so the
/// paywall is unavailable on web/desktop. Carries a user-facing message.
class PurchasesUnavailableException implements Exception {
  const PurchasesUnavailableException([
    this.message =
        'As assinaturas estão disponíveis apenas no app para Android e iOS.',
  ]);

  final String message;

  @override
  String toString() => message;
}
