import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';

part 'story_event.dart';

part 'story_state.dart';

@injectable
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  List<Story> stories = [];
  int _currentIndex = 0;

  StoryBloc() : super(const StoryStateLoading()) {
    on<StoryEventInit>(_init);
    on<StoryEventPlay>(_play);
    on<StoryEventPauseStories>(_pauseStories);
    on<StoryEventNextStory>(_handleNextStory);
    on<StoryEventNextFinish>(_finish);
  }

  FutureOr<void> _init(
    StoryEventInit event,
    Emitter<StoryState> emit,
  ) async {
    final list = event.stories.map((path) => Story(url: path)).toList();
    stories = list;
    _currentIndex = event.currentIndex;
    emit(StoryStateSetUpControllers(
      story: stories[event.currentIndex],
      stories: stories,
    ));
  }

  FutureOr<void> _handleNextStory(
    StoryEventNextStory event,
    Emitter<StoryState> emit,
  ) {
    final lastIndex = stories.length - 1;
    final nextIndex = _currentIndex + 1;

    if (nextIndex <= lastIndex) {
      _currentIndex = nextIndex;
      emit(StoryStateSetUpControllers(
        story: stories[nextIndex],
        stories: stories,
      ));
    } else {
      emit(const StoryStateFinished());
    }
  }

  FutureOr<void> _finish(
    StoryEventNextFinish event,
    Emitter<StoryState> emit,
  ) {
    _currentIndex = 0;
    stories.clear();
    emit(const StoryStateFinished());
  }

  FutureOr<void> _pauseStories(
    StoryEventPauseStories event,
    Emitter<StoryState> emit,
  ) {
    emit(const StoryStatePause());
  }

  FutureOr<void> _play(StoryEventPlay event, Emitter<StoryState> emit) {
    emit(StoryStateLoaded(story: event.currentStory, stories: event.stories));
  }
}
