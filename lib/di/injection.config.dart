// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:file_picker/file_picker.dart' as _i5;
import 'package:firebase_auth/firebase_auth.dart' as _i7;
import 'package:firebase_storage/firebase_storage.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/login/data/data_source/auth_remote_data_source.dart' as _i12;
import '../modules/login/data/external/firebase_auth_remote_data_source.dart'
    as _i13;
import '../modules/login/data/repository/auth_repository_impl.dart' as _i15;
import '../modules/login/domain/repository/auth_repository.dart' as _i14;
import '../modules/login/domain/use_case/sign_in_use_case.dart' as _i22;
import '../modules/login/presentation/bloc/login_bloc.dart' as _i31;
import '../modules/moment/domain/repository/moment_repository.dart' as _i32;
import '../modules/moment/domain/use_case/delete_moments_use_case.dart' as _i39;
import '../modules/moment/domain/use_case/get_moments_use_case.dart' as _i30;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i35;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i37;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i17;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i16;
import '../modules/moment/infra/models/moment_model.dart' as _i4;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i33;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i38;
import '../modules/photos/domain/repository/photos_repository.dart' as _i20;
import '../modules/photos/domain/use_case/delete_all_photos_from_moment_use_case.dart'
    as _i27;
import '../modules/photos/domain/use_case/delete_photo_use_case.dart' as _i28;
import '../modules/photos/domain/use_case/get_media_use_case.dart' as _i29;
import '../modules/photos/domain/use_case/upload_photo_use_case.dart' as _i26;
import '../modules/photos/external/file_picker_data_source.dart' as _i6;
import '../modules/photos/external/firebase_storage_photo_data_source.dart'
    as _i19;
import '../modules/photos/infra/data_source/photo_data_source.dart' as _i18;
import '../modules/photos/infra/repository/photos_repository_impl.dart' as _i21;
import '../modules/photos/presentation/bloc/photos_bloc.dart' as _i34;
import '../modules/signup/domain/sign_up_use_case.dart' as _i23;
import '../modules/signup/presentation/bloc/sign_up_bloc.dart' as _i36;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i11;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i24;
import '../modules/time_line/domain/use_case/get_month_use_case.dart' as _i8;
import '../modules/time_line/domain/use_case/get_year_use_case.dart' as _i9;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i25;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i40;
import 'modules/app_modules.dart' as _i42;
import 'modules/firebase_modules.dart' as _i41;

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
  gh.factory<_i7.FirebaseAuth>(() => firebaseModule.firebaseAuth);
  gh.factory<_i8.GetMonthUseCase>(() => _i8.GetMonthUseCase());
  gh.factory<_i9.GetYearUseCase>(() => _i9.GetYearUseCase());
  gh.factory<_i10.Reference>(
    () => firebaseModule.momentsPhotoRef,
    instanceName: 'photosStorage',
  );
  gh.factory<_i11.StoryBloc>(() => _i11.StoryBloc());
  gh.factory<_i12.AuthRemoteDataSource>(
      () => _i13.FirebaseAuthRemoteDataSource(gh<_i7.FirebaseAuth>()));
  gh.factory<_i14.AuthRepository>(
      () => _i15.AuthRepositoryImpl(gh<_i12.AuthRemoteDataSource>()));
  gh.factory<_i16.MomentsDataSource>(() => _i17.FirebaseMomentsDataSource(
        gh<_i3.CollectionReference<_i4.MomentModel>>(
            instanceName: 'momentsDBParam'),
        gh<_i10.Reference>(instanceName: 'photosStorage'),
      ));
  gh.factory<_i18.PhotoDataSource>(() => _i19.FirebaseStoragePhotoDataSource(
      gh<_i10.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i20.PhotosRepository>(() => _i21.PhotosRepositoryImpl(
        gh<_i18.PhotoDataSource>(),
        gh<_i6.FilePickerDataSource>(),
      ));
  gh.factory<_i22.SignInUseCase>(
      () => _i22.SignInUseCase(gh<_i14.AuthRepository>()));
  gh.factory<_i23.SignUpUseCase>(
      () => _i23.SignUpUseCase(gh<_i14.AuthRepository>()));
  gh.factory<_i24.TimeLineRepository>(() =>
      _i25.TimeLineRepositoryImpl(dataSource: gh<_i16.MomentsDataSource>()));
  gh.factory<_i26.UploadPhotoUseCase>(
      () => _i26.UploadPhotoUseCase(gh<_i20.PhotosRepository>()));
  gh.factory<_i27.ClearAllPhotosFromMomentUseCase>(
      () => _i27.ClearAllPhotosFromMomentUseCase(gh<_i20.PhotosRepository>()));
  gh.factory<_i28.DeletePhotoUseCase>(
      () => _i28.DeletePhotoUseCase(gh<_i20.PhotosRepository>()));
  gh.factory<_i29.GetMediaUseCase>(
      () => _i29.GetMediaUseCase(gh<_i20.PhotosRepository>()));
  gh.factory<_i30.GetMomentsUseCase>(
      () => _i30.GetMomentsUseCase(gh<_i24.TimeLineRepository>()));
  gh.factory<_i31.LoginBloc>(() => _i31.LoginBloc(gh<_i22.SignInUseCase>()));
  gh.factory<_i32.MomentRepository>(
      () => _i33.MomentRepositoryImpl(gh<_i16.MomentsDataSource>()));
  gh.factory<_i34.PhotosBloc>(
      () => _i34.PhotosBloc(gh<_i29.GetMediaUseCase>()));
  gh.factory<_i35.RegisterMomentsUseCase>(
      () => _i35.RegisterMomentsUseCase(gh<_i32.MomentRepository>()));
  gh.factory<_i36.SignUpBloc>(() => _i36.SignUpBloc(gh<_i23.SignUpUseCase>()));
  gh.factory<_i37.UpdateMomentUseCase>(
      () => _i37.UpdateMomentUseCase(gh<_i32.MomentRepository>()));
  gh.factory<_i38.AddOrEditMomentBloc>(() => _i38.AddOrEditMomentBloc(
        gh<_i37.UpdateMomentUseCase>(),
        gh<_i35.RegisterMomentsUseCase>(),
        gh<_i26.UploadPhotoUseCase>(),
        gh<_i28.DeletePhotoUseCase>(),
      ));
  gh.factory<_i39.DeleteMomentsUseCase>(
      () => _i39.DeleteMomentsUseCase(gh<_i32.MomentRepository>()));
  gh.factory<_i40.TimeLineBloc>(() => _i40.TimeLineBloc(
        gh<_i30.GetMomentsUseCase>(),
        gh<_i8.GetMonthUseCase>(),
        gh<_i9.GetYearUseCase>(),
        gh<_i39.DeleteMomentsUseCase>(),
        gh<_i27.ClearAllPhotosFromMomentUseCase>(),
      ));
  return getIt;
}

class _$FirebaseModule extends _i41.FirebaseModule {}

class _$AppModules extends _i42.AppModules {}
