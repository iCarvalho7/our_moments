import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/reaction.dart';
import '../../domain/use_case/add_comment_use_case.dart';
import '../../domain/use_case/add_reaction_use_case.dart';
import '../../domain/use_case/remove_comment_use_case.dart';
import '../../domain/use_case/remove_reaction_use_case.dart';
import '../../domain/use_case/watch_comments_use_case.dart';
import '../../domain/use_case/watch_reactions_use_case.dart';

part 'interactions_event.dart';

part 'interactions_state.dart';

@injectable
class InteractionsBloc extends Bloc<InteractionsEvent, InteractionsState> {
  final WatchReactionsUseCase watchReactionsUseCase;
  final WatchCommentsUseCase watchCommentsUseCase;
  final AddReactionUseCase addReactionUseCase;
  final AddCommentUseCase addCommentUseCase;
  final RemoveReactionUseCase removeReactionUseCase;
  final RemoveCommentUseCase removeCommentUseCase;

  StreamSubscription<List<Reaction>>? _reactionsSubscription;
  StreamSubscription<List<Comment>>? _commentsSubscription;

  InteractionsBloc(
    this.watchReactionsUseCase,
    this.watchCommentsUseCase,
    this.addReactionUseCase,
    this.addCommentUseCase,
    this.removeReactionUseCase,
    this.removeCommentUseCase,
  ) : super(const InteractionsState.initial()) {
    on<InteractionsStarted>(_onStarted);
    on<InteractionsReactionsUpdated>(_onReactionsUpdated);
    on<InteractionsCommentsUpdated>(_onCommentsUpdated);
    on<InteractionsReactionAdded>(_onReactionAdded);
    on<InteractionsCommentAdded>(_onCommentAdded);
  }

  FutureOr<void> _onStarted(
    InteractionsStarted event,
    Emitter<InteractionsState> emit,
  ) {
    emit(state.copyWith(momentId: event.momentId, isLoading: true));

    _reactionsSubscription?.cancel();
    _commentsSubscription?.cancel();

    _reactionsSubscription = watchReactionsUseCase.call(event.momentId).listen(
          (reactions) => add(InteractionsReactionsUpdated(reactions)),
        );
    _commentsSubscription = watchCommentsUseCase.call(event.momentId).listen(
          (comments) => add(InteractionsCommentsUpdated(comments)),
        );
  }

  FutureOr<void> _onReactionsUpdated(
    InteractionsReactionsUpdated event,
    Emitter<InteractionsState> emit,
  ) {
    emit(state.copyWith(reactions: event.reactions, isLoading: false));
  }

  FutureOr<void> _onCommentsUpdated(
    InteractionsCommentsUpdated event,
    Emitter<InteractionsState> emit,
  ) {
    emit(state.copyWith(comments: event.comments, isLoading: false));
  }

  FutureOr<void> _onReactionAdded(
    InteractionsReactionAdded event,
    Emitter<InteractionsState> emit,
  ) async {
    await addReactionUseCase.call(
      AddReactionParams(momentId: state.momentId, emoji: event.emoji),
    );
  }

  FutureOr<void> _onCommentAdded(
    InteractionsCommentAdded event,
    Emitter<InteractionsState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) {
      return;
    }
    await addCommentUseCase.call(
      AddCommentParams(momentId: state.momentId, text: text),
    );
  }

  @override
  Future<void> close() {
    _reactionsSubscription?.cancel();
    _commentsSubscription?.cancel();
    return super.close();
  }
}
