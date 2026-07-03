import 'package:injectable/injectable.dart';

import '../../../../core/use_case/use_case.dart';
import '../entity/bucket_item.dart';
import '../repository/bucket_list_repository.dart';

class AddBucketItemParams {
  final String timelineId;
  final String title;
  final String? category;
  final String? notes;

  const AddBucketItemParams({
    required this.timelineId,
    required this.title,
    this.category,
    this.notes,
  });
}

@injectable
class AddBucketItemUseCase extends AsyncUseCase<void, AddBucketItemParams> {
  final BucketListRepository _repository;

  AddBucketItemUseCase(this._repository);

  @override
  Future<void> execute(AddBucketItemParams params) {
    final title = params.title.trim();
    if (title.isEmpty) {
      throw Exception('Bucket item title cannot be empty.');
    }

    return _repository.add(
      params.timelineId,
      BucketItem(
        // Firestore generates the id; an empty placeholder is fine here.
        id: '',
        title: title,
        done: false,
        createdAt: DateTime.now(),
        category: params.category?.trim().isEmpty ?? true ? null : params.category!.trim(),
        notes: params.notes?.trim().isEmpty ?? true ? null : params.notes!.trim(),
      ),
    );
  }
}
