abstract class SelectTypeState {
  const SelectTypeState();
}

class SelectTypeStateLoaded extends SelectTypeState {
  final List<bool> selectedItems;

  const SelectTypeStateLoaded({required this.selectedItems});
}
