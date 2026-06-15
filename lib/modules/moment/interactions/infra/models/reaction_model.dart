import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/reaction.dart';

/// Firestore <-> [Reaction] mapping. Reads/writes are done with raw maps
/// (see the data source), so no json_serializable is needed here.
class ReactionModel extends Reaction {
  const ReactionModel({
    required super.id,
    required super.author,
    required super.emoji,
    required super.createdAt,
  });

  factory ReactionModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ReactionModel(
      id: id,
      author: data['author'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
    );
  }

  static DateTime _toDate(dynamic value) =>
      value is Timestamp ? value.toDate() : DateTime.now();

  Reaction toEntity() => Reaction(id: id, author: author, emoji: emoji, createdAt: createdAt);
}
