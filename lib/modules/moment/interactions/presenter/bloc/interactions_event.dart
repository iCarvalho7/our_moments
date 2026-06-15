part of 'interactions_bloc.dart';

abstract class InteractionsEvent {
  const InteractionsEvent();
}

class InteractionsStarted extends InteractionsEvent {
  final String momentId;

  const InteractionsStarted({required this.momentId});
}

class InteractionsReactionsUpdated extends InteractionsEvent {
  final List<Reaction> reactions;

  const InteractionsReactionsUpdated(this.reactions);
}

class InteractionsCommentsUpdated extends InteractionsEvent {
  final List<Comment> comments;

  const InteractionsCommentsUpdated(this.comments);
}

class InteractionsReactionAdded extends InteractionsEvent {
  final String emoji;

  const InteractionsReactionAdded(this.emoji);
}

class InteractionsCommentAdded extends InteractionsEvent {
  final String text;

  const InteractionsCommentAdded(this.text);
}

class InteractionsReactionRemoved extends InteractionsEvent {
  final String reactionId;

  const InteractionsReactionRemoved(this.reactionId);
}

class InteractionsCommentRemoved extends InteractionsEvent {
  final String commentId;

  const InteractionsCommentRemoved(this.commentId);
}
