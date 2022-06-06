abstract class AddDateState {
  final String text;

  const AddDateState({required this.text});
}

class AddDateStateInit extends AddDateState {

  const AddDateStateInit(String initialText) : super(text: initialText);
}
