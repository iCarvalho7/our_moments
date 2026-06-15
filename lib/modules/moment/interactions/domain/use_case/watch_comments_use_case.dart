import 'package:injectable/injectable.dart';

import '../entities/comment.dart';
import '../repository/interactions_repository.dart';

@injectable
class WatchCommentsUseCase {
  final InteractionsRepository _repository;

  WatchCommentsUseCase(this._repository);

  Stream<List<Comment>> call(String momentId) {
    return _repository.watchComments(momentId);
  }
}
