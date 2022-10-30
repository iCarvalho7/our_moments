import 'package:nossos_momentos/modules/stories/domain/story.dart';

abstract class StoryState {
  const StoryState();
}

class StoryStateLoading extends StoryState {
  const StoryStateLoading();
}

class StoryStateLoaded extends StoryState {
  final Story story;
  final List<Story> stories;
  const StoryStateLoaded({required this.story, required this.stories});
}

class StoryStatePause extends StoryState {
  const StoryStatePause();
}

class StoryStateFinished extends StoryState {
  const StoryStateFinished();
}
