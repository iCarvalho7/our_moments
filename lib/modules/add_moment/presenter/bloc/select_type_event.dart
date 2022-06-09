abstract class SelectMomentTypeEvent {
  const SelectMomentTypeEvent();
}

class SelectTypeEventSelectType extends SelectMomentTypeEvent {
  final int index;

  const SelectTypeEventSelectType({required this.index});
}
