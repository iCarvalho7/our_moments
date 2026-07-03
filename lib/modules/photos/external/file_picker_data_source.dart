import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';

@injectable
class FilePickerDataSource {
  final FilePicker filePicker;

  FilePickerDataSource(this.filePicker);

  Future<List<String?>?> getFiles() async {
    final files = await filePicker.pickFiles(
      allowMultiple: true,
      // On web there is no file system, so `path` is always null. Request the
      // bytes instead and carry each pick as a self-contained data URL that the
      // rest of the pipeline can both render and upload.
      withData: kIsWeb,
    );
    if (files == null) return null;

    if (kIsWeb) {
      return files.files.where((f) => f.bytes != null).map(_toDataUrl).toList();
    }
    return files.files.map((f) => f.path).toList();
  }

  String _toDataUrl(PlatformFile file) =>
      'data:${_mimeFor(file.extension)};base64,${base64Encode(file.bytes!)}';

  String _mimeFor(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'bmp':
        return 'image/bmp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      default:
        return 'application/octet-stream';
    }
  }
}
