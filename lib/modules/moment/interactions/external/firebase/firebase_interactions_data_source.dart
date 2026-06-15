import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../infra/data_source/interactions_data_source.dart';
import '../../infra/models/comment_model.dart';
import '../../infra/models/reaction_model.dart';

@Injectable(as: InteractionsDataSource)
class FirebaseInteractionsDataSource extends InteractionsDataSource {
  final CollectionReference<Map<String, dynamic>> momentsRef;

  FirebaseInteractionsDataSource(
    @Named(momentsRawCollectionParam) this.momentsRef,
  );

  static const String momentsRawCollectionParam = 'momentsRawCollectionParam';
  static const String reactionsCollection = 'reactions';
  static const String commentsCollection = 'comments';

  CollectionReference<Map<String, dynamic>> _reactionsRef(String momentId) =>
      momentsRef.doc(momentId).collection(reactionsCollection);

  CollectionReference<Map<String, dynamic>> _commentsRef(String momentId) =>
      momentsRef.doc(momentId).collection(commentsCollection);

  @override
  Stream<List<ReactionModel>> watchReactions(String momentId) {
    return _reactionsRef(momentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReactionModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> addReaction({
    required String momentId,
    required String author,
    required String emoji,
  }) {
    return _reactionsRef(momentId).add({
      'author': author,
      'emoji': emoji,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<void> removeReaction({
    required String momentId,
    required String reactionId,
  }) {
    return _reactionsRef(momentId).doc(reactionId).delete();
  }

  @override
  Stream<List<CommentModel>> watchComments(String momentId) {
    return _commentsRef(momentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> addComment({
    required String momentId,
    required String author,
    required String text,
  }) {
    return _commentsRef(momentId).add({
      'author': author,
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<void> removeComment({
    required String momentId,
    required String commentId,
  }) {
    return _commentsRef(momentId).doc(commentId).delete();
  }
}
