part of 'bucket_list_bloc.dart';

class BucketListState {
  final String timelineId;
  final List<BucketItem> items;
  final bool isLoading;

  const BucketListState({
    required this.timelineId,
    required this.items,
    required this.isLoading,
  });

  const BucketListState.initial()
      : timelineId = '',
        items = const [],
        isLoading = false;

  /// Items split into pending (not done) and accomplished (done), newest first
  /// within each group.
  List<BucketItem> get pending => items.where((i) => !i.done).toList();

  List<BucketItem> get accomplished => items.where((i) => i.done).toList();

  BucketListState copyWith({
    String? timelineId,
    List<BucketItem>? items,
    bool? isLoading,
  }) {
    return BucketListState(
      timelineId: timelineId ?? this.timelineId,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
