import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

import '../repository/interactions_repository.dart';

class AddCommentParams {
  final String momentId;
  final String text;

  const AddCommentParams({
    required this.momentId,
    required this.text,
  });
}

@injectable
class AddCommentUseCase extends AsyncUseCase<void, AddCommentParams> {
  final InteractionsRepository _repository;
  final AuthRepository _authRepository;

  AddCommentUseCase(this._repository, this._authRepository);

  @override
  Future<void> execute(AddCommentParams params) async {
    final user = _authRepository.getCurrentUser();
    final author = user?.email;

    if (author == null) {
      throw Exception('No authenticated user to attribute the comment.');
    }

    return _repository.addComment(
      momentId: params.momentId,
      author: author,
      text: params.text,
    );
  }
}
