import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../../../core/utils/data_url/data_url.dart';
import '../../../photos/domain/use_case/upload_photo_use_case.dart';
import '../entity/time_line.dart';
import '../repository/time_line_repository.dart';

class UpdateCoupleHeaderParams {
  final TimeLine timeline;

  /// Per-email nicknames to persist.
  final Map<String, String> nicknames;

  /// A freshly picked local cover (a file path on mobile, a `data:` URL on web)
  /// to upload before saving. Null keeps [keepCoverUrl].
  final String? localCoverPath;

  /// The existing remote cover URL to keep when no new photo was picked.
  /// Empty removes the cover.
  final String keepCoverUrl;

  const UpdateCoupleHeaderParams({
    required this.timeline,
    required this.nicknames,
    this.localCoverPath,
    this.keepCoverUrl = '',
  });
}

/// Uploads a freshly picked couple cover (when provided) and persists the
/// couple header (cover URL + nicknames) onto the timeline doc.
@injectable
class UpdateCoupleHeaderUseCase extends AsyncUseCase<TimeLine, UpdateCoupleHeaderParams> {
  final TimeLineRepository repository;
  final UploadPhotoUseCase uploadPhotoUseCase;

  const UpdateCoupleHeaderUseCase(this.repository, this.uploadPhotoUseCase);

  @override
  Future<TimeLine> execute(UpdateCoupleHeaderParams params) async {
    final coverUrl = await _resolveCoverUrl(params);
    return repository.updateCoupleHeader(
      params.timeline,
      coverPhotoUrl: coverUrl,
      nicknames: params.nicknames,
    );
  }

  /// Uploads the picked local cover if any, otherwise keeps the existing URL.
  /// Covers live under a stable per-timeline storage folder.
  Future<String> _resolveCoverUrl(UpdateCoupleHeaderParams params) async {
    final local = params.localCoverPath;
    if (local == null || local.isEmpty) return params.keepCoverUrl;

    final folder = 'cover_${params.timeline.id}';
    final fileName = 'cover_${params.timeline.id}_${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      final bytes = decodeDataUrl(local);
      if (bytes == null) return params.keepCoverUrl;
      return uploadPhotoUseCase.uploadPhotoBytes(
        bytes,
        folder,
        '$fileName${dataUrlExtension(local)}',
      );
    }

    final result = await uploadPhotoUseCase.call(
      PhotoParams(paths: [local], momentId: folder),
    );
    final urls = result.isSuccess ? result.data : null;
    if (urls == null || urls.isEmpty) return params.keepCoverUrl;
    return urls.first;
  }
}
