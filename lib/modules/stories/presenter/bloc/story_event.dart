import 'package:nossos_momentos/modules/stories/domain/story.dart';

abstract class StoryEvent {
  const StoryEvent();
}

class StoryEventInit extends StoryEvent {
  final List<Story> stories;
  final int currentIndex;

  const StoryEventInit({
    required this.stories,
    required this.currentIndex,
  });
}

class StoryEventNextStory extends StoryEvent {
  const StoryEventNextStory();
}

class StoryEventNextFinish extends StoryEvent {
  const StoryEventNextFinish();
}
