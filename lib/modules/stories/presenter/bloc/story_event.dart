abstract class StoryEvent {
  const StoryEvent();
}

class StoryEventInit extends StoryEvent {
  final List<String> stories;
  final int currentIndex;

  const StoryEventInit({
    required this.stories,
    required this.currentIndex,
  });
}

class StoryEventPauseStories extends StoryEvent {
  const StoryEventPauseStories();
}

class StoryEventNextStory extends StoryEvent {
  const StoryEventNextStory();
}

class StoryEventNextFinish extends StoryEvent {
  const StoryEventNextFinish();
}
