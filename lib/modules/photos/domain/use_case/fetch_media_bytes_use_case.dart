import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/photos/domain/repository/photos_repository.dart';

@injectable
class FetchMediaBytesUseCase
    extends AsyncUseCase<({Uint8List bytes, String? contentType}), String> {
  const FetchMediaBytesUseCase(this._repository);

  final PhotosRepository _repository;

  @override
  Future<({Uint8List bytes, String? contentType})> execute(String url) async {
    final result = await _repository.fetchBytes(url);
    if (result == null) throw Exception('fetchBytes returned null for $url');
    return result;
  }
}
