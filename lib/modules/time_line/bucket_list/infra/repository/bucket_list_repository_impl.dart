import 'package:injectable/injectable.dart';

import '../../domain/entity/bucket_item.dart';
import '../../domain/repository/bucket_list_repository.dart';
import '../data_source/bucket_list_data_source.dart';
import '../model/bucket_item_model.dart';

@Injectable(as: BucketListRepository)
class BucketListRepositoryImpl extends BucketListRepository {
  final BucketListDataSource _dataSource;

  BucketListRepositoryImpl(this._dataSource);

  @override
  Stream<List<BucketItem>> watch(String timelineId) {
    return _dataSource
        .watch(timelineId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<void> add(String timelineId, BucketItem item) {
    return _dataSource.add(
      timelineId,
      BucketItemModel(
        id: item.id,
        title: item.title,
        done: item.done,
        createdAt: item.createdAt,
        category: item.category,
        notes: item.notes,
      ),
    );
  }

  @override
  Future<void> toggle(String timelineId, String id, bool done) {
    return _dataSource.toggle(timelineId, id, done);
  }

  @override
  Future<void> remove(String timelineId, String id) {
    return _dataSource.remove(timelineId, id);
  }
}
