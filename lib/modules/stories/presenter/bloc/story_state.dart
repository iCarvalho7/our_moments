import 'package:nossos_momentos/modules/stories/domain/story.dart';

abstract class StoryState {
  const StoryState();
}

class StoryStateLoading extends StoryState {
  const StoryStateLoading();
}

class StoryStateLoaded extends StoryState {
  final Story story;

  const StoryStateLoaded({required this.story});
}

class StoryStateFinished extends StoryState {
  const StoryStateFinished();
}
