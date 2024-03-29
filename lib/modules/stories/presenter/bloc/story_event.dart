part of 'story_bloc.dart';

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

class StoryEventPlay extends StoryEvent {
  final Story currentStory;
  final List<Story> stories;

  const StoryEventPlay({required this.currentStory, required this.stories});
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
