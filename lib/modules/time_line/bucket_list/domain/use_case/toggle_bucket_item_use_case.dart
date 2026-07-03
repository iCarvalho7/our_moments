import 'package:injectable/injectable.dart';

import '../../../../core/use_case/use_case.dart';
import '../repository/bucket_list_repository.dart';

class ToggleBucketItemParams {
  final String timelineId;
  final String id;
  final bool done;

  const ToggleBucketItemParams({
    required this.timelineId,
    required this.id,
    required this.done,
  });
}

@injectable
class ToggleBucketItemUseCase extends AsyncUseCase<void, ToggleBucketItemParams> {
  final BucketListRepository _repository;

  ToggleBucketItemUseCase(this._repository);

  @override
  Future<void> execute(ToggleBucketItemParams params) =>
      _repository.toggle(params.timelineId, params.id, params.done);
}
