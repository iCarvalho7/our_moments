part of 'select_type_bloc.dart';

abstract class SelectTypeEvent {
  const SelectTypeEvent();
}

class SelectTypeEventSelectType extends SelectTypeEvent {
  final int index;

  const SelectTypeEventSelectType({required this.index});
}
