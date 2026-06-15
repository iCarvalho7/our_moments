import 'package:injectable/injectable.dart';

import '../entities/reaction.dart';
import '../repository/interactions_repository.dart';

@injectable
class WatchReactionsUseCase {
  final InteractionsRepository _repository;

  WatchReactionsUseCase(this._repository);

  Stream<List<Reaction>> call(String momentId) {
    return _repository.watchReactions(momentId);
  }
}
