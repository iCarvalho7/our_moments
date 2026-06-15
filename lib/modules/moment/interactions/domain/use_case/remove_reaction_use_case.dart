import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../repository/interactions_repository.dart';

class RemoveReactionParams {
  final String momentId;
  final String reactionId;

  const RemoveReactionParams({
    required this.momentId,
    required this.reactionId,
  });
}

@injectable
class RemoveReactionUseCase extends AsyncUseCase<void, RemoveReactionParams> {
  final InteractionsRepository _repository;

  RemoveReactionUseCase(this._repository);

  @override
  Future<void> execute(RemoveReactionParams params) {
    return _repository.removeReaction(
      momentId: params.momentId,
      reactionId: params.reactionId,
    );
  }
}
