import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/stories/domain/story.dart';
import 'package:nossos_momentos/modules/stories/presenter/bloc/story_event.dart';
import 'package:nossos_momentos/modules/stories/presenter/bloc/story_state.dart';

@injectable
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  List<Story> _stories = [];
  int _currentIndex = 0;

  StoryBloc() : super(const StoryStateLoading()) {
    on<StoryEventInit>(_init);
    on<StoryEventNextStory>(_handleNextStory);
    on<StoryEventNextFinish>(_finish);
  }

  FutureOr<void> _init(
    StoryEventInit event,
    Emitter<StoryState> emit,
  ) async {
    _stories = event.stories;
    _currentIndex = event.currentIndex;

    emit(StoryStateLoaded(story: _stories[event.currentIndex]));
  }

  FutureOr<void> _handleNextStory(
    StoryEventNextStory event,
    Emitter<StoryState> emit,
  ) {
    final lastIndex = _stories.length - 1;
    final nextIndex = _currentIndex + 1;

    if (nextIndex < lastIndex) {
      _currentIndex = nextIndex;
      emit(StoryStateLoaded(story: _stories[nextIndex]));
    } else {
      emit(const StoryStateFinished());
    }
  }

  FutureOr<void> _finish(
    StoryEventNextFinish event,
    Emitter<StoryState> emit,
  ) {
    _currentIndex = 0;
    _stories.clear();
    emit(const StoryStateFinished());
  }
}
