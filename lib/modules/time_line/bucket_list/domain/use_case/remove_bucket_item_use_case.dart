import 'package:injectable/injectable.dart';

import '../../../../core/use_case/use_case.dart';
import '../repository/bucket_list_repository.dart';

class RemoveBucketItemParams {
  final String timelineId;
  final String id;

  const RemoveBucketItemParams({required this.timelineId, required this.id});
}

@injectable
class RemoveBucketItemUseCase extends AsyncUseCase<void, RemoveBucketItemParams> {
  final BucketListRepository _repository;

  RemoveBucketItemUseCase(this._repository);

  @override
  Future<void> execute(RemoveBucketItemParams params) =>
      _repository.remove(params.timelineId, params.id);
}
