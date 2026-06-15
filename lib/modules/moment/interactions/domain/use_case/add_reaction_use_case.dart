import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

import '../repository/interactions_repository.dart';

class AddReactionParams {
  final String momentId;
  final String emoji;

  const AddReactionParams({
    required this.momentId,
    required this.emoji,
  });
}

@injectable
class AddReactionUseCase extends AsyncUseCase<void, AddReactionParams> {
  final InteractionsRepository _repository;
  final AuthRepository _authRepository;

  AddReactionUseCase(this._repository, this._authRepository);

  @override
  Future<void> execute(AddReactionParams params) async {
    final user = _authRepository.getCurrentUser();
    final author = user?.email;

    if (author == null) {
      throw Exception('No authenticated user to attribute the reaction.');
    }

    return _repository.addReaction(
      momentId: params.momentId,
      author: author,
      emoji: params.emoji,
    );
  }
}
