part of 'interactions_bloc.dart';

class InteractionsState {
  final String momentId;
  final List<Reaction> reactions;
  final List<Comment> comments;
  final bool isLoading;

  const InteractionsState({
    required this.momentId,
    required this.reactions,
    required this.comments,
    required this.isLoading,
  });

  const InteractionsState.initial()
      : momentId = '',
        reactions = const [],
        comments = const [],
        isLoading = false;

  InteractionsState copyWith({
    String? momentId,
    List<Reaction>? reactions,
    List<Comment>? comments,
    bool? isLoading,
  }) {
    return InteractionsState(
      momentId: momentId ?? this.momentId,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
