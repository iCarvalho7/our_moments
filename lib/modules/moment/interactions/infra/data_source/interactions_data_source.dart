import '../models/comment_model.dart';
import '../models/reaction_model.dart';

abstract class InteractionsDataSource {
  Stream<List<ReactionModel>> watchReactions(String momentId);

  Future<void> addReaction({
    required String momentId,
    required String author,
    required String emoji,
  });

  Future<void> removeReaction({
    required String momentId,
    required String reactionId,
  });

  Stream<List<CommentModel>> watchComments(String momentId);

  Future<void> addComment({
    required String momentId,
    required String author,
    required String text,
  });

  Future<void> removeComment({
    required String momentId,
    required String commentId,
  });
}
