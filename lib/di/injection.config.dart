// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:cloud_firestore/cloud_firestore.dart' as _i4;
import 'package:firebase_storage/firebase_storage.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/add_moment/domain/repository/get_moment_repository.dart'
    as _i23;
import '../modules/add_moment/domain/repository/register_moment_repository.dart'
    as _i11;
import '../modules/add_moment/domain/use_case/get_moment_by_id_use_case.dart'
    as _i33;
import '../modules/add_moment/domain/use_case/register_moments_use_case.dart'
    as _i13;
import '../modules/add_moment/external/firebase/firebase_moments_data_source.dart'
    as _i9;
import '../modules/add_moment/infra/data_source/moments_data_source.dart'
    as _i8;
import '../modules/add_moment/infra/models/moment_model.dart' as _i6;
import '../modules/add_moment/infra/repository/get_moment_repository_impl.dart'
    as _i24;
import '../modules/add_moment/infra/repository/register_moment_repository_impl.dart'
    as _i12;
import '../modules/add_moment/presenter/bloc/add_date_bloc.dart' as _i3;
import '../modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart'
    as _i34;
import '../modules/add_moment/presenter/bloc/stories_bloc.dart' as _i7;
import '../modules/add_moment/presenter/bloc/select_type_bloc.dart' as _i14;
import '../modules/edit_moment/domain/repository/edit_moment_repository.dart'
    as _i21;
import '../modules/edit_moment/domain/use_case/update_moment_use_case.dart'
    as _i29;
import '../modules/edit_moment/external/firebase/firebase_edit_moment_data_source.dart'
    as _i20;
import '../modules/edit_moment/infra/data_source/update_moment_data_source.dart'
    as _i19;
import '../modules/edit_moment/infra/repository/edit_moment_repository_impl.dart'
    as _i22;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i17;
import '../modules/time_line/domain/use_case/get_moments_use_case.dart' as _i25;
import '../modules/time_line/external/firebase/firebase_timeline_data_sourse.dart'
    as _i16;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i15;
import '../modules/time_line/infra/models/time_line_moment_model.dart' as _i5;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i18;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i28;
import '../modules/upload_photo/domain/repository/upload_photo_repository.dart'
    as _i30;
import '../modules/upload_photo/domain/use_case/upload_photo_use_case.dart'
    as _i32;
import '../modules/upload_photo/external/firebase_storage_photo_data_source.dart'
    as _i27;
import '../modules/upload_photo/infra/data_source/photo_data_source.dart'
    as _i26;
import '../modules/upload_photo/infra/repository/upload_photo_repository_impl.dart'
    as _i31;
import 'modules/firebase_modules.dart'
    as _i35; // ignore_for_file: unnecessary_lambdas

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
  gh.factory<_i7.StoriesBloc>(() => _i7.StoriesBloc());
  gh.factory<_i8.MomentsDataSource>(() => _i9.FirebaseMomentsDataSource(
      get<_i4.CollectionReference<_i6.MomentModel>>(
          instanceName: 'momentsDBParam')));
  gh.factory<_i10.Reference>(() => firebaseModule.momentsPhotoRef,
      instanceName: 'photosStorage');
  gh.factory<_i11.RegisterMomentRepository>(
      () => _i12.RegisterMomentRepositoryImpl(get<_i8.MomentsDataSource>()));
  gh.factory<_i13.RegisterMomentsUseCase>(
      () => _i13.RegisterMomentsUseCase(get<_i11.RegisterMomentRepository>()));
  gh.factory<_i14.SelectTypeBloc>(() => _i14.SelectTypeBloc());
  gh.factory<_i15.TimeLineDataSource>(() => _i16.FirebaseTimeLineDataSource(
      get<_i4.CollectionReference<_i5.TimeLineMomentModel>>(
          instanceName: 'timelineDBParam')));
  gh.factory<_i17.TimeLineRepository>(() =>
      _i18.TimeLineRepositoryImpl(dataSource: get<_i15.TimeLineDataSource>()));
  gh.factory<_i19.UpdateMomentDataSource>(() =>
      _i20.FirebaseEditMomentDataSource(
          get<_i4.CollectionReference<_i6.MomentModel>>(
              instanceName: 'momentsDBParam')));
  gh.factory<_i21.EditMomentRepository>(
      () => _i22.EditMomentRepositoryImpl(get<_i19.UpdateMomentDataSource>()));
  gh.factory<_i23.GetMomentRepository>(
      () => _i24.GetMomentRepositoryImpl(get<_i8.MomentsDataSource>()));
  gh.factory<_i25.GetMomentsUseCase>(
      () => _i25.GetMomentsUseCaseImpl(get<_i17.TimeLineRepository>()));
  gh.factory<_i26.PhotoDataSource>(() => _i27.FirebaseStoragePhotoDataSource(
      get<_i10.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i28.TimeLineBloc>(
      () => _i28.TimeLineBloc(get<_i25.GetMomentsUseCase>()));
  gh.factory<_i29.UpdateMomentUseCase>(
      () => _i29.UpdateMomentUseCase(get<_i21.EditMomentRepository>()));
  gh.factory<_i30.UploadPhotoRepository>(
      () => _i31.UploadPhotoRepositoryImpl(get<_i26.PhotoDataSource>()));
  gh.factory<_i32.UploadPhotoUseCase>(
      () => _i32.UploadPhotoUseCase(get<_i30.UploadPhotoRepository>()));
  gh.factory<_i33.GetMomentByIdUseCase>(
      () => _i33.GetMomentByIdUseCase(get<_i23.GetMomentRepository>()));
  gh.factory<_i34.AddOrEditMomentBloc>(() => _i34.AddOrEditMomentBloc(
      get<_i29.UpdateMomentUseCase>(),
      get<_i13.RegisterMomentsUseCase>(),
      get<_i32.UploadPhotoUseCase>(),
      get<_i33.GetMomentByIdUseCase>()));
  return get;
}

class _$FirebaseModule extends _i35.FirebaseModule {}
