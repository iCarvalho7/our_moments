part of 'bucket_list_bloc.dart';

abstract class BucketListEvent {
  const BucketListEvent();
}

class BucketListStarted extends BucketListEvent {
  final String timelineId;

  const BucketListStarted({required this.timelineId});
}

class BucketListUpdated extends BucketListEvent {
  final List<BucketItem> items;

  const BucketListUpdated(this.items);
}

class BucketListItemAdded extends BucketListEvent {
  final String title;
  final String? category;
  final String? notes;

  const BucketListItemAdded({required this.title, this.category, this.notes});
}

class BucketListItemToggled extends BucketListEvent {
  final String id;
  final bool done;

  const BucketListItemToggled({required this.id, required this.done});
}

class BucketListItemRemoved extends BucketListEvent {
  final String id;

  const BucketListItemRemoved(this.id);
}
