import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/moment/domain/repository/moment_repository.dart';

class DeleteAuthoredMomentsInTimelineParams {
  final String timelineId;
  final String authorEmail;

  const DeleteAuthoredMomentsInTimelineParams({
    required this.timelineId,
    required this.authorEmail,
  });
}

/// Deletes every moment authored by [authorEmail] inside a timeline, together
/// with its media (photos/audio) on Storage. Used for the LGPD "delete my
/// moments" flow when a user leaves a timeline or deletes their account.
@injectable
class DeleteAuthoredMomentsInTimelineUseCase
    extends AsyncUseCase<void, DeleteAuthoredMomentsInTimelineParams> {
  final MomentRepository _momentRepository;

  DeleteAuthoredMomentsInTimelineUseCase(this._momentRepository);

  @override
  Future<void> execute(DeleteAuthoredMomentsInTimelineParams params) async {
    final moments = await _momentRepository.getMomentsByAuthorInTimeline(
      params.timelineId,
      params.authorEmail,
    );

    for (final moment in moments) {
      // Best-effort media cleanup: uploaded photos + audio note.
      final media = <String>[
        ...moment.uploadedImgList,
        if (moment.audioUrl.isNotEmpty) moment.audioUrl,
      ];
      if (media.isNotEmpty) {
        await _momentRepository.deleteMomentMedia(media);
      }
      await _momentRepository.deleteMoment(moment.id);
    }
  }
}
