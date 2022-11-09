// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:cloud_firestore/cloud_firestore.dart' as _i4;
import 'package:firebase_storage/firebase_storage.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/moment/domain/repository/moment_repository.dart' as _i23;
import '../modules/moment/domain/use_case/get_moment_by_id_use_case.dart'
    as _i28;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i25;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i26;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i17;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i16;
import '../modules/moment/infra/models/moment_model.dart' as _i6;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i24;
import '../modules/moment/presenter/bloc/add_date_bloc.dart' as _i3;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i30;
import '../modules/moment/presenter/bloc/photos_bloc.dart' as _i7;
import '../modules/moment/presenter/bloc/select_type_bloc.dart' as _i9;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i10;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i13;
import '../modules/time_line/domain/use_case/delete_moments_use_case.dart'
    as _i27;
import '../modules/time_line/domain/use_case/get_moments_use_case.dart' as _i15;
import '../modules/time_line/external/firebase/firebase_timeline_data_sourse.dart'
    as _i12;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i11;
import '../modules/time_line/infra/models/time_line_moment_model.dart' as _i5;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i14;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i29;
import '../modules/upload_photo/domain/repository/upload_photo_repository.dart'
    as _i20;
import '../modules/upload_photo/domain/use_case/upload_photo_use_case.dart'
    as _i22;
import '../modules/upload_photo/external/firebase_storage_photo_data_source.dart'
    as _i19;
import '../modules/upload_photo/infra/data_source/photo_data_source.dart'
    as _i18;
import '../modules/upload_photo/infra/repository/upload_photo_repository_impl.dart'
    as _i21;
import 'modules/firebase_modules.dart'
    as _i31; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i3.AddDateBloc>(() => _i3.AddDateBloc());
  gh.factory<_i4.CollectionReference<_i5.TimeLineMomentModel>>(
      () => firebaseModule.timelineDBParam,
      instanceName: 'timelineDBParam');
  gh.factory<_i4.CollectionReference<_i6.MomentModel>>(
      () => firebaseModule.momentsDBRef,
      instanceName: 'momentsDBParam');
  gh.factory<_i7.PhotosBloc>(() => _i7.PhotosBloc());
  gh.factory<_i8.Reference>(() => firebaseModule.momentsPhotoRef,
      instanceName: 'photosStorage');
  gh.factory<_i9.SelectTypeBloc>(() => _i9.SelectTypeBloc());
  gh.factory<_i10.StoryBloc>(() => _i10.StoryBloc());
  gh.factory<_i11.TimeLineDataSource>(() => _i12.FirebaseTimeLineDataSource(
      get<_i4.CollectionReference<_i5.TimeLineMomentModel>>(
          instanceName: 'timelineDBParam')));
  gh.factory<_i13.TimeLineRepository>(() =>
      _i14.TimeLineRepositoryImpl(dataSource: get<_i11.TimeLineDataSource>()));
  gh.factory<_i15.GetMomentsUseCase>(
      () => _i15.GetMomentsUseCaseImpl(get<_i13.TimeLineRepository>()));
  gh.factory<_i16.MomentsDataSource>(() => _i17.FirebaseMomentsDataSource(
      get<_i4.CollectionReference<_i6.MomentModel>>(
          instanceName: 'momentsDBParam'),
      get<_i8.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i18.PhotoDataSource>(() => _i19.FirebaseStoragePhotoDataSource(
      get<_i8.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i20.UploadPhotoRepository>(
      () => _i21.UploadPhotoRepositoryImpl(get<_i18.PhotoDataSource>()));
  gh.factory<_i22.UploadPhotoUseCase>(
      () => _i22.UploadPhotoUseCase(get<_i20.UploadPhotoRepository>()));
  gh.factory<_i23.MomentRepository>(
      () => _i24.MomentRepositoryImpl(get<_i16.MomentsDataSource>()));
  gh.factory<_i25.RegisterMomentsUseCase>(
      () => _i25.RegisterMomentsUseCase(get<_i23.MomentRepository>()));
  gh.factory<_i26.UpdateMomentUseCase>(
      () => _i26.UpdateMomentUseCase(get<_i23.MomentRepository>()));
  gh.factory<_i27.DeleteMomentsUseCase>(
      () => _i27.DeleteMomentsUseCaseImpl(get<_i23.MomentRepository>()));
  gh.factory<_i28.GetMomentByIdUseCase>(
      () => _i28.GetMomentByIdUseCase(get<_i23.MomentRepository>()));
  gh.factory<_i29.TimeLineBloc>(() => _i29.TimeLineBloc(
      get<_i15.GetMomentsUseCase>(), get<_i27.DeleteMomentsUseCase>()));
  gh.factory<_i30.AddOrEditMomentBloc>(() => _i30.AddOrEditMomentBloc(
      get<_i26.UpdateMomentUseCase>(),
      get<_i25.RegisterMomentsUseCase>(),
      get<_i22.UploadPhotoUseCase>(),
      get<_i28.GetMomentByIdUseCase>()));
  return get;
}

class _$FirebaseModule extends _i31.FirebaseModule {}
