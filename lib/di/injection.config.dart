// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:file_picker/file_picker.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i8;
import 'package:firebase_storage/firebase_storage.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/login/data/data_source/auth_remote_data_source.dart' as _i14;
import '../modules/login/data/external/firebase_auth_remote_data_source.dart'
    as _i15;
import '../modules/login/data/repository/auth_repository_impl.dart' as _i17;
import '../modules/login/domain/repository/auth_repository.dart' as _i16;
import '../modules/login/domain/use_case/is_user_authenticated_use_case.dart'
    as _i18;
import '../modules/login/domain/use_case/sign_in_use_case.dart' as _i26;
import '../modules/login/presentation/bloc/login_bloc.dart' as _i37;
import '../modules/moment/domain/repository/moment_repository.dart' as _i38;
import '../modules/moment/domain/use_case/delete_moments_use_case.dart' as _i46;
import '../modules/moment/domain/use_case/get_moments_use_case.dart' as _i35;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i41;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i44;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i21;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i20;
import '../modules/moment/infra/models/moment_model.dart' as _i5;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i39;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i45;
import '../modules/photos/domain/repository/photos_repository.dart' as _i24;
import '../modules/photos/domain/use_case/delete_all_photos_from_moment_use_case.dart'
    as _i31;
import '../modules/photos/domain/use_case/delete_photo_use_case.dart' as _i33;
import '../modules/photos/domain/use_case/get_media_use_case.dart' as _i34;
import '../modules/photos/domain/use_case/upload_photo_use_case.dart' as _i30;
import '../modules/photos/external/file_picker_data_source.dart' as _i7;
import '../modules/photos/external/firebase_storage_photo_data_source.dart'
    as _i23;
import '../modules/photos/infra/data_source/photo_data_source.dart' as _i22;
import '../modules/photos/infra/repository/photos_repository_impl.dart' as _i25;
import '../modules/photos/presentation/bloc/photos_bloc.dart' as _i40;
import '../modules/signup/domain/sign_up_use_case.dart' as _i27;
import '../modules/signup/presentation/bloc/sign_up_bloc.dart' as _i43;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i12;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i28;
import '../modules/time_line/domain/use_case/create_time_line_use_case.dart'
    as _i32;
import '../modules/time_line/domain/use_case/get_month_use_case.dart' as _i9;
import '../modules/time_line/domain/use_case/get_time_line_from_email_use_case.dart'
    as _i36;
import '../modules/time_line/domain/use_case/get_year_use_case.dart' as _i10;
import '../modules/time_line/domain/use_case/logout_use_case.dart' as _i19;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i13;
import '../modules/time_line/infra/model/time_line_model.dart' as _i4;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i29;
import '../modules/time_line/presenter/bloc/select_time_line_bloc.dart' as _i42;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i47;
import 'modules/app_modules.dart' as _i49;
import 'modules/firebase_modules.dart' as _i48;

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
  gh.factory<_i3.CollectionReference<_i4.TimeLineModel>>(
    () => firebaseModule.timelineDbRef,
    instanceName: 'timeline',
  );
  gh.factory<_i3.CollectionReference<_i5.MomentModel>>(
    () => firebaseModule.momentsDBRef,
    instanceName: 'momentsDBParam',
  );
  gh.factory<_i6.FilePicker>(() => appModules.filePicker);
  gh.factory<_i7.FilePickerDataSource>(
      () => _i7.FilePickerDataSource(gh<_i6.FilePicker>()));
  gh.factory<_i8.FirebaseAuth>(() => firebaseModule.firebaseAuth);
  gh.factory<_i9.GetMonthUseCase>(() => _i9.GetMonthUseCase());
  gh.factory<_i10.GetYearUseCase>(() => _i10.GetYearUseCase());
  gh.factory<_i11.Reference>(
    () => firebaseModule.momentsPhotoRef,
    instanceName: 'photosStorage',
  );
  gh.factory<_i12.StoryBloc>(() => _i12.StoryBloc());
  gh.factory<_i13.TimeLineDataSource>(() =>
      _i13.FirebaseTimelineRemoteDataSourceImpl(
          gh<_i3.CollectionReference<_i4.TimeLineModel>>(
              instanceName: 'timeline')));
  gh.factory<_i14.AuthRemoteDataSource>(
      () => _i15.FirebaseAuthRemoteDataSource(gh<_i8.FirebaseAuth>()));
  gh.factory<_i16.AuthRepository>(
      () => _i17.AuthRepositoryImpl(gh<_i14.AuthRemoteDataSource>()));
  gh.factory<_i18.IsUserAuthenticatedUseCase>(
      () => _i18.IsUserAuthenticatedUseCase(gh<_i16.AuthRepository>()));
  gh.factory<_i19.LogoutUseCase>(
      () => _i19.LogoutUseCase(gh<_i16.AuthRepository>()));
  gh.factory<_i20.MomentsDataSource>(() => _i21.FirebaseMomentsDataSource(
        gh<_i3.CollectionReference<_i5.MomentModel>>(
            instanceName: 'momentsDBParam'),
        gh<_i11.Reference>(instanceName: 'photosStorage'),
      ));
  gh.factory<_i22.PhotoDataSource>(() => _i23.FirebaseStoragePhotoDataSource(
      gh<_i11.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i24.PhotosRepository>(() => _i25.PhotosRepositoryImpl(
        gh<_i22.PhotoDataSource>(),
        gh<_i7.FilePickerDataSource>(),
      ));
  gh.factory<_i26.SignInUseCase>(
      () => _i26.SignInUseCase(gh<_i16.AuthRepository>()));
  gh.factory<_i27.SignUpUseCase>(
      () => _i27.SignUpUseCase(gh<_i16.AuthRepository>()));
  gh.factory<_i28.TimeLineRepository>(() => _i29.TimeLineRepositoryImpl(
        momentsDataSource: gh<_i20.MomentsDataSource>(),
        timeLineDataSource: gh<_i13.TimeLineDataSource>(),
      ));
  gh.factory<_i30.UploadPhotoUseCase>(
      () => _i30.UploadPhotoUseCase(gh<_i24.PhotosRepository>()));
  gh.factory<_i31.ClearAllPhotosFromMomentUseCase>(
      () => _i31.ClearAllPhotosFromMomentUseCase(gh<_i24.PhotosRepository>()));
  gh.factory<_i32.CreateTimeLineUseCase>(() => _i32.CreateTimeLineUseCase(
        gh<_i28.TimeLineRepository>(),
        gh<_i16.AuthRepository>(),
      ));
  gh.factory<_i33.DeletePhotoUseCase>(
      () => _i33.DeletePhotoUseCase(gh<_i24.PhotosRepository>()));
  gh.factory<_i34.GetMediaUseCase>(
      () => _i34.GetMediaUseCase(gh<_i24.PhotosRepository>()));
  gh.factory<_i35.GetMomentsUseCase>(
      () => _i35.GetMomentsUseCase(gh<_i28.TimeLineRepository>()));
  gh.factory<_i36.GetTimeLineFromEmailUseCase>(
      () => _i36.GetTimeLineFromEmailUseCase(
            gh<_i16.AuthRepository>(),
            gh<_i28.TimeLineRepository>(),
          ));
  gh.factory<_i37.LoginBloc>(() => _i37.LoginBloc(
        gh<_i26.SignInUseCase>(),
        gh<_i18.IsUserAuthenticatedUseCase>(),
      ));
  gh.factory<_i38.MomentRepository>(
      () => _i39.MomentRepositoryImpl(gh<_i20.MomentsDataSource>()));
  gh.factory<_i40.PhotosBloc>(
      () => _i40.PhotosBloc(gh<_i34.GetMediaUseCase>()));
  gh.factory<_i41.RegisterMomentsUseCase>(() => _i41.RegisterMomentsUseCase(
        gh<_i38.MomentRepository>(),
        gh<_i28.TimeLineRepository>(),
      ));
  gh.factory<_i42.SelectTimeLineBloc>(() => _i42.SelectTimeLineBloc(
        gh<_i36.GetTimeLineFromEmailUseCase>(),
        gh<_i19.LogoutUseCase>(),
      ));
  gh.factory<_i43.SignUpBloc>(() => _i43.SignUpBloc(gh<_i27.SignUpUseCase>()));
  gh.factory<_i44.UpdateMomentUseCase>(
      () => _i44.UpdateMomentUseCase(gh<_i38.MomentRepository>()));
  gh.factory<_i45.AddOrEditMomentBloc>(() => _i45.AddOrEditMomentBloc(
        gh<_i44.UpdateMomentUseCase>(),
        gh<_i41.RegisterMomentsUseCase>(),
        gh<_i30.UploadPhotoUseCase>(),
        gh<_i33.DeletePhotoUseCase>(),
      ));
  gh.factory<_i46.DeleteMomentsUseCase>(
      () => _i46.DeleteMomentsUseCase(gh<_i38.MomentRepository>()));
  gh.factory<_i47.TimeLineBloc>(() => _i47.TimeLineBloc(
        gh<_i35.GetMomentsUseCase>(),
        gh<_i9.GetMonthUseCase>(),
        gh<_i10.GetYearUseCase>(),
        gh<_i46.DeleteMomentsUseCase>(),
        gh<_i31.ClearAllPhotosFromMomentUseCase>(),
        gh<_i32.CreateTimeLineUseCase>(),
      ));
  return getIt;
}

class _$FirebaseModule extends _i48.FirebaseModule {}

class _$AppModules extends _i49.AppModules {}
