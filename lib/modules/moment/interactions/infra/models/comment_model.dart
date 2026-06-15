import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment.dart';

/// Firestore <-> [Comment] mapping. Reads/writes are done with raw maps
/// (see the data source), so no json_serializable is needed here.
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.author,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CommentModel(
      id: id,
      author: data['author'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
    );
  }

  static DateTime _toDate(dynamic value) =>
      value is Timestamp ? value.toDate() : DateTime.now();

  Comment toEntity() => Comment(id: id, author: author, text: text, createdAt: createdAt);
}
