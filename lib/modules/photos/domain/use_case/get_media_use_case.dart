import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/photos/domain/repository/photos_repository.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';

@injectable
class GetMediaUseCase extends AsyncUseCase<List<Story>, NoParams> {
  final PhotosRepository _repository;

  GetMediaUseCase(this._repository);

  @override
  Future<List<Story>> execute(NoParams params) async {
    final list = await _repository.getMedia();
    return list.skipWhile((value) => value.type == StoryType.undefined).toList();
  }
}
