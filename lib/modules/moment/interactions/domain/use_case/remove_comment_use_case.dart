import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../repository/interactions_repository.dart';

class RemoveCommentParams {
  final String momentId;
  final String commentId;

  const RemoveCommentParams({
    required this.momentId,
    required this.commentId,
  });
}

@injectable
class RemoveCommentUseCase extends AsyncUseCase<void, RemoveCommentParams> {
  final InteractionsRepository _repository;

  RemoveCommentUseCase(this._repository);

  @override
  Future<void> execute(RemoveCommentParams params) {
    return _repository.removeComment(
      momentId: params.momentId,
      commentId: params.commentId,
    );
  }
}
