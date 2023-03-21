// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:firebase_storage/firebase_storage.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/moment/domain/repository/moment_repository.dart' as _i18;
import '../modules/moment/domain/use_case/get_moment_by_id_use_case.dart'
    as _i23;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i20;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i21;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i9;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i8;
import '../modules/moment/infra/models/moment_model.dart' as _i4;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i19;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i25;
import '../modules/moment/presenter/bloc/photos_bloc.dart' as _i5;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i7;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i12;
import '../modules/time_line/domain/use_case/delete_moments_use_case.dart'
    as _i22;
import '../modules/time_line/domain/use_case/get_moments_use_case.dart' as _i17;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i13;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i24;
import '../modules/upload_photo/domain/repository/upload_photo_repository.dart'
    as _i14;
import '../modules/upload_photo/domain/use_case/upload_photo_use_case.dart'
    as _i16;
import '../modules/upload_photo/external/firebase_storage_photo_data_source.dart'
    as _i11;
import '../modules/upload_photo/infra/data_source/photo_data_source.dart'
    as _i10;
import '../modules/upload_photo/infra/repository/upload_photo_repository_impl.dart'
    as _i15;
import 'modules/firebase_modules.dart'
    as _i26; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i3.CollectionReference<_i4.MomentModel>>(
      () => firebaseModule.momentsDBRef,
      instanceName: 'momentsDBParam');
  gh.factory<_i5.PhotosBloc>(() => _i5.PhotosBloc());
  gh.factory<_i6.Reference>(() => firebaseModule.momentsPhotoRef,
      instanceName: 'photosStorage');
  gh.factory<_i7.StoryBloc>(() => _i7.StoryBloc());
  gh.factory<_i8.MomentsDataSource>(() => _i9.FirebaseMomentsDataSource(
      get<_i3.CollectionReference<_i4.MomentModel>>(
          instanceName: 'momentsDBParam'),
      get<_i6.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i10.PhotoDataSource>(() => _i11.FirebaseStoragePhotoDataSource(
      get<_i6.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i12.TimeLineRepository>(() =>
      _i13.TimeLineRepositoryImpl(dataSource: get<_i8.MomentsDataSource>()));
  gh.factory<_i14.UploadPhotoRepository>(
      () => _i15.UploadPhotoRepositoryImpl(get<_i10.PhotoDataSource>()));
  gh.factory<_i16.UploadPhotoUseCase>(
      () => _i16.UploadPhotoUseCase(get<_i14.UploadPhotoRepository>()));
  gh.factory<_i17.GetMomentsUseCase>(
      () => _i17.GetMomentsUseCaseImpl(get<_i12.TimeLineRepository>()));
  gh.factory<_i18.MomentRepository>(
      () => _i19.MomentRepositoryImpl(get<_i8.MomentsDataSource>()));
  gh.factory<_i20.RegisterMomentsUseCase>(
      () => _i20.RegisterMomentsUseCase(get<_i18.MomentRepository>()));
  gh.factory<_i21.UpdateMomentUseCase>(
      () => _i21.UpdateMomentUseCase(get<_i18.MomentRepository>()));
  gh.factory<_i22.DeleteMomentsUseCase>(
      () => _i22.DeleteMomentsUseCaseImpl(get<_i18.MomentRepository>()));
  gh.factory<_i23.GetMomentByIdUseCase>(
      () => _i23.GetMomentByIdUseCase(get<_i18.MomentRepository>()));
  gh.factory<_i24.TimeLineBloc>(() => _i24.TimeLineBloc(
      get<_i17.GetMomentsUseCase>(), get<_i22.DeleteMomentsUseCase>()));
  gh.factory<_i25.AddOrEditMomentBloc>(() => _i25.AddOrEditMomentBloc(
      get<_i21.UpdateMomentUseCase>(),
      get<_i20.RegisterMomentsUseCase>(),
      get<_i16.UploadPhotoUseCase>(),
      get<_i23.GetMomentByIdUseCase>()));
  return get;
}

class _$FirebaseModule extends _i26.FirebaseModule {}
