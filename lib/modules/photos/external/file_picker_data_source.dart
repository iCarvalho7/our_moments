import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';

@injectable
class FilePickerDataSource {
  final FilePicker filePicker;

  FilePickerDataSource(this.filePicker);

  Future<List<String?>?> getFiles() async {
    final files = await filePicker.pickFiles(
      allowMultiple: true,
    );
    final list = files?.files.map((e) => e.path).toList();
    return list;
  }
}
