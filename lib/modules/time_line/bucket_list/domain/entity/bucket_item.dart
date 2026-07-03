class BucketItem {
  final String id;
  final String title;
  final bool done;
  final String? category;
  final String? notes;
  final DateTime createdAt;

  const BucketItem({
    required this.id,
    required this.title,
    required this.done,
    required this.createdAt,
    this.category,
    this.notes,
  });
}
