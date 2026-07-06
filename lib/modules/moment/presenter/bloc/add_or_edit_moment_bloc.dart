import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/utils/data_url/data_url.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import '../../../photos/domain/use_case/delete_photo_use_case.dart';
import '../../../photos/domain/use_case/fetch_media_bytes_use_case.dart';
import '../../domain/entities/moment.dart';
import '../../domain/entities/moment_type.dart';
import '../../domain/use_case/delete_moments_use_case.dart';
import '../../domain/use_case/register_moments_use_case.dart';
import '../../domain/use_case/update_moment_use_case.dart';
import '../../../photos/domain/use_case/upload_photo_use_case.dart';

part 'add_or_edit_moment_event.dart';

part 'add_or_edit_moment_state.dart';

@injectable
class AddOrEditMomentBloc extends Bloc<AddOrEditMomentEvent, AddOrEditMomentState> {
  final RegisterMomentsUseCase registerMomentsUseCase;
  final UploadPhotoUseCase uploadPhotoUseCase;
  final UpdateMomentUseCase updateMomentUseCase;
  final DeletePhotoUseCase deletePhotoUseCase;
  final DeleteMomentsUseCase deleteMomentsUseCase;
  final AuthRepository authRepository;
  final FetchMediaBytesUseCase fetchMediaBytesUseCase;

  Moment? _originalMoment;

  /// True when in edit mode and the user has changed at least one field.
  bool get isDirty {
    final orig = _originalMoment;
    if (orig == null) return false;
    final m = state.moment;
    return m.title != orig.title ||
        m.body != orig.body ||
        m.dateTime != orig.dateTime ||
        m.type != orig.type ||
        m.locationName != orig.locationName ||
        m.audioUrl != orig.audioUrl ||
        m.downloadUrlList.length != orig.downloadUrlList.length ||
        state.photosToDelete.isNotEmpty;
  }

  AddOrEditMomentBloc(
    this.updateMomentUseCase,
    this.registerMomentsUseCase,
    this.uploadPhotoUseCase,
    this.deletePhotoUseCase,
    this.deleteMomentsUseCase,
    this.authRepository,
    this.fetchMediaBytesUseCase,
  ) : super(AddOrEditMomentStateEmpty(timeLineId: '')) {
    on<SetupAddMomentEvent>(_handleShowEmpty);
    on<SetupEditMomentEvent>(_handleEditMoment);
    on<AddOrEditMomentEventSelectType>(_handleSelectType);
    on<AddOrEditMomentEventAddMedia>(_handleAddPhoto);
    on<AddOrEditMomentEventDeletePhoto>(_handleDeletePhoto);
    on<AddOrEditMomentEventAddDateTime>(_handleAddTimeEvent);
    on<AddOrEditMomentEventTypeTitle>(_handleTypeTitle);
    on<AddOrEditMomentEvenTypeBodyText>(_handleTypeBodyText);
    on<AddOrEditMomentEventTypeLocation>(_handleTypeLocation);
    on<AddOrEditMomentEventSetLocation>(_handleSetLocation);
    on<AddOrEditMomentEventSetAudio>(_handleSetAudio);
    on<AddOrEditMomentEventRemoveAudio>(_handleRemoveAudio);
    on<AddOrEditMomentEventCreateOrUpdateMoment>(_handleCreateOrUpdateMoment);
    on<AddOrEditMomentEventDeleteMoment>(_handleDeleteMoment);
  }

  FutureOr<void> _handleSetAudio(
    AddOrEditMomentEventSetAudio event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(audioUrl: event.path),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleRemoveAudio(
    AddOrEditMomentEventRemoveAudio event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(audioUrl: ''),
      photosToDelete: state.photosToDelete,
    ));
  }

  Future<String> _resolveAudioUrl() async {
    final audio = state.moment.audioUrl;
    if (audio.isEmpty) return audio;

    // On web a freshly recorded note is a blob: URL (which also contains
    // "http"), while an already saved note is a remote https URL. Blobs live
    // only in memory, so they must be read as bytes and uploaded.
    if (kIsWeb) {
      if (!audio.startsWith('blob:')) return audio;
      final blob = await _fetchBlob(audio);
      if (blob == null) return '';
      // The recording format varies by browser (opus/webm, or AAC/mp4 on
      // Safari), so derive the extension from the blob's real content type.
      final fileName = 'recado_${state.moment.id}${_audioExtension(blob.contentType)}';
      return uploadPhotoUseCase.uploadAudioBytes(blob.bytes, state.moment.id, fileName);
    }

    // Mobile: a local file path is uploaded through the file-based pipeline.
    if (audio.isHttpUrl) return audio;
    final res = await uploadPhotoUseCase.call(PhotoParams(paths: [audio], momentId: state.moment.id));
    if (res.isSuccess && res.data!.isNotEmpty) return res.data!.first;
    return audio;
  }

  Future<({Uint8List bytes, String? contentType})?> _fetchBlob(String blobUrl) async {
    final result = await fetchMediaBytesUseCase.call(blobUrl);
    return result.data;
  }

  String _audioExtension(String? contentType) {
    final type = contentType ?? '';
    if (type.contains('ogg')) return '.ogg';
    if (type.contains('mp4') || type.contains('aac') || type.contains('m4a')) return '.m4a';
    return '.webm';
  }

  FutureOr<void> _handleTypeLocation(
    AddOrEditMomentEventTypeLocation event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(locationName: event.location),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleSetLocation(
    AddOrEditMomentEventSetLocation event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        latitude: event.latitude,
        longitude: event.longitude,
        locationName: event.name,
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleShowEmpty(
    SetupAddMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateEmpty(timeLineId: event.timelineId));
  }

  FutureOr<void> _handleSelectType(
    AddOrEditMomentEventSelectType event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        type: event.type,
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleAddPhoto(
    AddOrEditMomentEventAddMedia event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    final photos = state.moment.downloadUrlList.toList()..addAll(event.medias);

    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(downloadUrlList: photos),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleDeletePhoto(
    AddOrEditMomentEventDeletePhoto event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    final newList = state.moment.downloadUrlList.toList()..remove(event.photo);
    emit(
      AddOrEditMomentStateUpdate(
        moment: state.moment.copyWith(downloadUrlList: newList),
        photosToDelete:
            event.photo.isHttpUrl ? [...state.photosToDelete, event.photo] : state.photosToDelete,
      ),
    );
  }

  FutureOr<void> _handleAddTimeEvent(
    AddOrEditMomentEventAddDateTime event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        dateTime: event.date,
        year: event.date.year.toString(),
        month: TimeLineBloc.monthsName[event.date.month - 1],
        monthDay: event.date.day.toString(),
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleTypeTitle(
    AddOrEditMomentEventTypeTitle event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        title: event.title,
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleTypeBodyText(
    AddOrEditMomentEvenTypeBodyText event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        body: event.bodyText,
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleCreateOrUpdateMoment(
    AddOrEditMomentEventCreateOrUpdateMoment event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateLoading(moment: state.moment, photosToDelete: state.photosToDelete));

    if (!state.moment.isEditing) {
      await _createMoment(emit);
    } else {
      await _editMoment(emit);
    }
  }

  Future<void> _createMoment(Emitter<AddOrEditMomentState> emit) async {
    final uploaded = await _uploadLocalPhotos();
    if (uploaded == null) {
      emit(AddOrEditMomentStateError(moment: state.moment, photosToDelete: state.photosToDelete));
      return;
    }

    final audioUrl = await _resolveAudioUrl();
    // Stamp authorship only on creation; editing preserves the original author.
    final moment = state.moment.copyWith(
      downloadUrlList: [...uploaded, ...state.moment.uploadedImgList],
      audioUrl: audioUrl,
      author: authRepository.getCurrentUser()?.email ?? '',
    );
    await registerMomentsUseCase.call(moment);
    emit(AddOrEditMomentStateUpdate(
      moment: moment,
      photosToDelete: [],
    ));
  }

  FutureOr<void> _editMoment(Emitter<AddOrEditMomentState> emit) async {
    final deleteResult = await deletePhotoUseCase(PhotoParams(
      paths: state.photosToDelete,
      momentId: state.moment.id,
    ));

    final uploaded = await _uploadLocalPhotos();

    if (uploaded == null || !deleteResult.isSuccess) {
      emit(AddOrEditMomentStateError(moment: state.moment, photosToDelete: state.photosToDelete));
      return;
    }

    final audioUrl = await _resolveAudioUrl();
    final editedMoment = state.moment.copyWith(
      downloadUrlList: [...uploaded, ...state.moment.uploadedImgList],
      audioUrl: audioUrl,
    );
    await updateMomentUseCase(editedMoment);

    emit(AddOrEditMomentStateUpdate(
      moment: editedMoment,
      photosToDelete: [],
    ));
  }

  /// Uploads the moment's freshly-added local photos and returns their remote
  /// URLs (download URLs of already-uploaded photos are not re-uploaded here).
  /// On web the picks are in-memory data URLs with no file path, so they are
  /// decoded and uploaded as bytes; on mobile they are file paths sent through
  /// the file-based pipeline. Returns null if any upload fails.
  Future<List<String>?> _uploadLocalPhotos() async {
    final locals = state.moment.localImgList;
    if (locals.isEmpty) return [];

    if (kIsWeb) {
      try {
        final urls = <String>[];
        for (final dataUrl in locals) {
          final bytes = decodeDataUrl(dataUrl);
          if (bytes == null) continue;
          final fileName =
              'photo_${state.moment.id}_${urls.length}${dataUrlExtension(dataUrl)}';
          urls.add(await uploadPhotoUseCase.uploadPhotoBytes(bytes, state.moment.id, fileName));
        }
        return urls;
      } catch (_) {
        return null;
      }
    }

    final result = await uploadPhotoUseCase.call(PhotoParams(
      paths: locals,
      momentId: state.moment.id,
    ));
    return result.isSuccess ? result.data : null;
  }

  FutureOr<void> _handleEditMoment(
    SetupEditMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    _originalMoment = event.moment;
    emit(AddOrEditMomentStateUpdate(
      moment: event.moment.copyWith(isEditing: true),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleDeleteMoment(
    AddOrEditMomentEventDeleteMoment event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateLoading(moment: state.moment, photosToDelete: state.photosToDelete));
    try {
      await deleteMomentsUseCase(state.moment.id);
      emit(AddOrEditMomentStateDeleted(moment: state.moment, photosToDelete: []));
    } catch (_) {
      emit(AddOrEditMomentStateError(moment: state.moment, photosToDelete: state.photosToDelete));
    }
  }

  static final defaultDateTime = DateTime(0, 0, 0);
}
