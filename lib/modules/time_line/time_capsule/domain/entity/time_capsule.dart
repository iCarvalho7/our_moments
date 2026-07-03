class TimeCapsule {
  final String id;
  final String message;
  final String mediaUrl;
  final DateTime revealDate;
  final String fromEmail;
  final String toEmail;
  final bool revealed;

  const TimeCapsule({
    required this.id,
    required this.message,
    required this.revealDate,
    required this.fromEmail,
    required this.toEmail,
    this.mediaUrl = '',
    this.revealed = false,
  });

  /// Whether the capsule can be opened now (client-side reveal).
  bool isRevealedAt(DateTime now) => !now.isBefore(revealDate);
}
