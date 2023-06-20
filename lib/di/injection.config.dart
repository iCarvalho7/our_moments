// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:file_picker/file_picker.dart' as _i5;
import 'package:firebase_storage/firebase_storage.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/moment/domain/repository/moment_repository.dart' as _i24;
import '../modules/moment/domain/use_case/delete_moments_use_case.dart' as _i30;
import '../modules/moment/domain/use_case/get_moments_use_case.dart' as _i23;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i27;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i28;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i12;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i11;
import '../modules/moment/infra/models/moment_model.dart' as _i4;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i25;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i29;
import '../modules/photos/domain/repository/photos_repository.dart' as _i15;
import '../modules/photos/domain/use_case/delete_all_photos_from_moment_use_case.dart'
    as _i20;
import '../modules/photos/domain/use_case/delete_photo_use_case.dart' as _i21;
import '../modules/photos/domain/use_case/get_media_use_case.dart' as _i22;
import '../modules/photos/domain/use_case/upload_photo_use_case.dart' as _i19;
import '../modules/photos/external/file_picker_data_source.dart' as _i6;
import '../modules/photos/external/firebase_storage_photo_data_source.dart'
    as _i14;
import '../modules/photos/infra/data_source/photo_data_source.dart' as _i13;
import '../modules/photos/infra/repository/photos_repository_impl.dart' as _i16;
import '../modules/photos/presentation/bloc/photos_bloc.dart' as _i26;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i10;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i17;
import '../modules/time_line/domain/use_case/get_month_use_case.dart' as _i7;
import '../modules/time_line/domain/use_case/get_year_use_case.dart' as _i8;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i18;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i31;
import 'modules/app_modules.dart' as _i32;
import 'modules/firebase_modules.dart' as _i33;

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// initializes the registration of main-scope dependencies inside of GetIt
_i1.GetIt $initGetIt(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final firebaseModule = _$FirebaseModule();
  final appModules = _$AppModules();
  gh.factory<_i3.CollectionReference<_i4.MomentModel>>(
    () => firebaseModule.momentsDBRef,
    instanceName: 'momentsDBParam',
  );
  gh.factory<_i5.FilePicker>(() => appModules.filePicker);
  gh.factory<_i6.FilePickerDataSource>(
      () => _i6.FilePickerDataSource(gh<_i5.FilePicker>()));
  gh.factory<_i7.GetMonthUseCase>(() => _i7.GetMonthUseCase());
  gh.factory<_i8.GetYearUseCase>(() => _i8.GetYearUseCase());
  gh.factory<_i9.Reference>(
    () => firebaseModule.momentsPhotoRef,
    instanceName: 'photosStorage',
  );
  gh.factory<_i10.StoryBloc>(() => _i10.StoryBloc());
  gh.factory<_i11.MomentsDataSource>(() => _i12.FirebaseMomentsDataSource(
        gh<_i3.CollectionReference<_i4.MomentModel>>(
            instanceName: 'momentsDBParam'),
        gh<_i9.Reference>(instanceName: 'photosStorage'),
      ));
  gh.factory<_i13.PhotoDataSource>(() => _i14.FirebaseStoragePhotoDataSource(
      gh<_i9.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i15.PhotosRepository>(() => _i16.PhotosRepositoryImpl(
        gh<_i13.PhotoDataSource>(),
        gh<_i6.FilePickerDataSource>(),
      ));
  gh.factory<_i17.TimeLineRepository>(() =>
      _i18.TimeLineRepositoryImpl(dataSource: gh<_i11.MomentsDataSource>()));
  gh.factory<_i19.UploadPhotoUseCase>(
      () => _i19.UploadPhotoUseCase(gh<_i15.PhotosRepository>()));
  gh.factory<_i20.ClearAllPhotosFromMomentUseCase>(
      () => _i20.ClearAllPhotosFromMomentUseCase(gh<_i15.PhotosRepository>()));
  gh.factory<_i21.DeletePhotoUseCase>(
      () => _i21.DeletePhotoUseCase(gh<_i15.PhotosRepository>()));
  gh.factory<_i22.GetMediaUseCase>(
      () => _i22.GetMediaUseCase(gh<_i15.PhotosRepository>()));
  gh.factory<_i23.GetMomentsUseCase>(
      () => _i23.GetMomentsUseCase(gh<_i17.TimeLineRepository>()));
  gh.factory<_i24.MomentRepository>(
      () => _i25.MomentRepositoryImpl(gh<_i11.MomentsDataSource>()));
  gh.factory<_i26.PhotosBloc>(
      () => _i26.PhotosBloc(gh<_i22.GetMediaUseCase>()));
  gh.factory<_i27.RegisterMomentsUseCase>(
      () => _i27.RegisterMomentsUseCase(gh<_i24.MomentRepository>()));
  gh.factory<_i28.UpdateMomentUseCase>(
      () => _i28.UpdateMomentUseCase(gh<_i24.MomentRepository>()));
  gh.factory<_i29.AddOrEditMomentBloc>(() => _i29.AddOrEditMomentBloc(
        gh<_i28.UpdateMomentUseCase>(),
        gh<_i27.RegisterMomentsUseCase>(),
        gh<_i19.UploadPhotoUseCase>(),
        gh<_i21.DeletePhotoUseCase>(),
      ));
  gh.factory<_i30.DeleteMomentsUseCase>(
      () => _i30.DeleteMomentsUseCase(gh<_i24.MomentRepository>()));
  gh.factory<_i31.TimeLineBloc>(() => _i31.TimeLineBloc(
        gh<_i23.GetMomentsUseCase>(),
        gh<_i7.GetMonthUseCase>(),
        gh<_i8.GetYearUseCase>(),
        gh<_i30.DeleteMomentsUseCase>(),
        gh<_i20.ClearAllPhotosFromMomentUseCase>(),
      ));
  return getIt;
}

class _$AppModules extends _i32.AppModules {}

class _$FirebaseModule extends _i33.FirebaseModule {}
