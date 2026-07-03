import 'package:injectable/injectable.dart';

import '../entity/bucket_item.dart';
import '../repository/bucket_list_repository.dart';

@injectable
class WatchBucketListUseCase {
  final BucketListRepository _repository;

  WatchBucketListUseCase(this._repository);

  Stream<List<BucketItem>> call(String timelineId) {
    return _repository.watch(timelineId);
  }
}
