import 'package:injectable/injectable.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/reaction.dart';
import '../../domain/repository/interactions_repository.dart';
import '../data_source/interactions_data_source.dart';

@Injectable(as: InteractionsRepository)
class InteractionsRepositoryImpl extends InteractionsRepository {
  final InteractionsDataSource _dataSource;

  InteractionsRepositoryImpl(this._dataSource);

  @override
  Stream<List<Reaction>> watchReactions(String momentId) {
    return _dataSource
        .watchReactions(momentId)
        .map((reactions) => reactions.map((e) => e.toEntity()).toList());
  }

  @override
  Future<void> addReaction({
    required String momentId,
    required String author,
    required String emoji,
  }) {
    return _dataSource.addReaction(
      momentId: momentId,
      author: author,
      emoji: emoji,
    );
  }

  @override
  Future<void> removeReaction({
    required String momentId,
    required String reactionId,
  }) {
    return _dataSource.removeReaction(
      momentId: momentId,
      reactionId: reactionId,
    );
  }

  @override
  Stream<List<Comment>> watchComments(String momentId) {
    return _dataSource
        .watchComments(momentId)
        .map((comments) => comments.map((e) => e.toEntity()).toList());
  }

  @override
  Future<void> addComment({
    required String momentId,
    required String author,
    required String text,
  }) {
    return _dataSource.addComment(
      momentId: momentId,
      author: author,
      text: text,
    );
  }

  @override
  Future<void> removeComment({
    required String momentId,
    required String commentId,
  }) {
    return _dataSource.removeComment(
      momentId: momentId,
      commentId: commentId,
    );
  }
}
