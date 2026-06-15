class Reaction {
  final String id;
  final String author;
  final String emoji;
  final DateTime createdAt;

  const Reaction({
    required this.id,
    required this.author,
    required this.emoji,
    required this.createdAt,
  });
}
