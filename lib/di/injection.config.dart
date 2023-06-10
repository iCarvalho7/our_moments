// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:firebase_storage/firebase_storage.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/moment/domain/repository/moment_repository.dart' as _i20;
import '../modules/moment/domain/use_case/get_moment_by_id_use_case.dart'
    as _i25;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i22;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i23;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i11;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i10;
import '../modules/moment/infra/models/moment_model.dart' as _i4;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i21;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i27;
import '../modules/moment/presenter/bloc/photos_bloc.dart' as _i7;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i9;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i14;
import '../modules/time_line/domain/use_case/delete_moments_use_case.dart'
    as _i24;
import '../modules/time_line/domain/use_case/get_moments_use_case.dart' as _i19;
import '../modules/time_line/domain/use_case/get_month_use_case.dart' as _i5;
import '../modules/time_line/domain/use_case/get_year_use_case.dart' as _i6;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i15;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i26;
import '../modules/upload_photo/domain/repository/upload_photo_repository.dart'
    as _i16;
import '../modules/upload_photo/domain/use_case/upload_photo_use_case.dart'
    as _i18;
import '../modules/upload_photo/external/firebase_storage_photo_data_source.dart'
    as _i13;
import '../modules/upload_photo/infra/data_source/photo_data_source.dart'
    as _i12;
import '../modules/upload_photo/infra/repository/upload_photo_repository_impl.dart'
    as _i17;
import 'modules/firebase_modules.dart' as _i28;

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
  gh.factory<_i3.CollectionReference<_i4.MomentModel>>(
    () => firebaseModule.momentsDBRef,
    instanceName: 'momentsDBParam',
  );
  gh.factory<_i5.GetMonthUseCase>(() => _i5.GetMonthUseCase());
  gh.factory<_i6.GetYearUseCase>(() => _i6.GetYearUseCase());
  gh.factory<_i7.PhotosBloc>(() => _i7.PhotosBloc());
  gh.factory<_i8.Reference>(
    () => firebaseModule.momentsPhotoRef,
    instanceName: 'photosStorage',
  );
  gh.factory<_i9.StoryBloc>(() => _i9.StoryBloc());
  gh.factory<_i10.MomentsDataSource>(() => _i11.FirebaseMomentsDataSource(
        gh<_i3.CollectionReference<_i4.MomentModel>>(
            instanceName: 'momentsDBParam'),
        gh<_i8.Reference>(instanceName: 'photosStorage'),
      ));
  gh.factory<_i12.PhotoDataSource>(() => _i13.FirebaseStoragePhotoDataSource(
      gh<_i8.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i14.TimeLineRepository>(() =>
      _i15.TimeLineRepositoryImpl(dataSource: gh<_i10.MomentsDataSource>()));
  gh.factory<_i16.UploadPhotoRepository>(
      () => _i17.UploadPhotoRepositoryImpl(gh<_i12.PhotoDataSource>()));
  gh.factory<_i18.UploadPhotoUseCase>(
      () => _i18.UploadPhotoUseCase(gh<_i16.UploadPhotoRepository>()));
  gh.factory<_i19.GetMomentsUseCase>(
      () => _i19.GetMomentsUseCaseImpl(gh<_i14.TimeLineRepository>()));
  gh.factory<_i20.MomentRepository>(
      () => _i21.MomentRepositoryImpl(gh<_i10.MomentsDataSource>()));
  gh.factory<_i22.RegisterMomentsUseCase>(
      () => _i22.RegisterMomentsUseCase(gh<_i20.MomentRepository>()));
  gh.factory<_i23.UpdateMomentUseCase>(
      () => _i23.UpdateMomentUseCase(gh<_i20.MomentRepository>()));
  gh.factory<_i24.DeleteMomentsUseCase>(
      () => _i24.DeleteMomentsUseCaseImpl(gh<_i20.MomentRepository>()));
  gh.factory<_i25.GetMomentByIdUseCase>(
      () => _i25.GetMomentByIdUseCase(gh<_i20.MomentRepository>()));
  gh.factory<_i26.TimeLineBloc>(() => _i26.TimeLineBloc(
        gh<_i19.GetMomentsUseCase>(),
        gh<_i5.GetMonthUseCase>(),
        gh<_i6.GetYearUseCase>(),
        gh<_i24.DeleteMomentsUseCase>(),
      ));
  gh.factory<_i27.AddOrEditMomentBloc>(() => _i27.AddOrEditMomentBloc(
        gh<_i23.UpdateMomentUseCase>(),
        gh<_i22.RegisterMomentsUseCase>(),
        gh<_i18.UploadPhotoUseCase>(),
        gh<_i25.GetMomentByIdUseCase>(),
      ));
  return getIt;
}

class _$FirebaseModule extends _i28.FirebaseModule {}
