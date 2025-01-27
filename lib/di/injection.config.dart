// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:file_picker/file_picker.dart' as _i388;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../modules/login/data/data_source/auth_remote_data_source.dart'
    as _i283;
import '../modules/login/data/external/firebase_auth_remote_data_source.dart'
    as _i678;
import '../modules/login/data/repository/auth_repository_impl.dart' as _i401;
import '../modules/login/domain/repository/auth_repository.dart' as _i884;
import '../modules/login/domain/use_case/is_user_authenticated_use_case.dart'
    as _i393;
import '../modules/login/domain/use_case/sign_in_use_case.dart' as _i518;
import '../modules/login/presentation/bloc/login_bloc.dart' as _i260;
import '../modules/moment/domain/repository/moment_repository.dart' as _i980;
import '../modules/moment/domain/use_case/delete_moments_use_case.dart'
    as _i183;
import '../modules/moment/domain/use_case/get_moments_use_case.dart' as _i589;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i663;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i272;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i1056;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i771;
import '../modules/moment/infra/models/moment_model.dart' as _i797;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i775;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i321;
import '../modules/photos/domain/repository/photos_repository.dart' as _i179;
import '../modules/photos/domain/use_case/delete_all_photos_from_moment_use_case.dart'
    as _i522;
import '../modules/photos/domain/use_case/delete_photo_use_case.dart' as _i271;
import '../modules/photos/domain/use_case/get_media_use_case.dart' as _i465;
import '../modules/photos/domain/use_case/upload_photo_use_case.dart' as _i262;
import '../modules/photos/external/file_picker_data_source.dart' as _i370;
import '../modules/photos/external/firebase_storage_photo_data_source.dart'
    as _i320;
import '../modules/photos/infra/data_source/photo_data_source.dart' as _i592;
import '../modules/photos/infra/repository/photos_repository_impl.dart'
    as _i724;
import '../modules/photos/presentation/bloc/photos_bloc.dart' as _i876;
import '../modules/signup/domain/sign_up_use_case.dart' as _i480;
import '../modules/signup/presentation/bloc/sign_up_bloc.dart' as _i773;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i211;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i184;
import '../modules/time_line/domain/use_case/create_time_line_use_case.dart'
    as _i283;
import '../modules/time_line/domain/use_case/get_month_use_case.dart' as _i341;
import '../modules/time_line/domain/use_case/get_time_line_from_email_use_case.dart'
    as _i783;
import '../modules/time_line/domain/use_case/get_year_use_case.dart' as _i970;
import '../modules/time_line/domain/use_case/logout_use_case.dart' as _i44;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i1061;
import '../modules/time_line/infra/model/time_line_model.dart' as _i452;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i294;
import '../modules/time_line/presenter/bloc/select_time_line_bloc.dart' as _i11;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i716;
import 'modules/app_modules.dart' as _i1023;
import 'modules/firebase_modules.dart' as _i279;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final appModules = _$AppModules();
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i388.FilePicker>(() => appModules.filePicker);
  gh.factory<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
  gh.factory<_i211.StoryBloc>(() => _i211.StoryBloc());
  gh.factory<_i341.GetMonthUseCase>(() => _i341.GetMonthUseCase());
  gh.factory<_i970.GetYearUseCase>(() => _i970.GetYearUseCase());
  gh.factory<_i974.CollectionReference<_i797.MomentModel>>(
    () => firebaseModule.momentsDBRef,
    instanceName: 'momentsDBParam',
  );
  gh.factory<_i457.Reference>(
    () => firebaseModule.momentsPhotoRef,
    instanceName: 'photosStorage',
  );
  gh.factory<_i370.FilePickerDataSource>(
      () => _i370.FilePickerDataSource(gh<_i388.FilePicker>()));
  gh.factory<_i771.MomentsDataSource>(() => _i1056.FirebaseMomentsDataSource(
        gh<_i974.CollectionReference<_i797.MomentModel>>(
            instanceName: 'momentsDBParam'),
        gh<_i457.Reference>(instanceName: 'photosStorage'),
      ));
  gh.factory<_i974.CollectionReference<_i452.TimeLineModel>>(
    () => firebaseModule.timelineDbRef,
    instanceName: 'timeline',
  );
  gh.factory<_i592.PhotoDataSource>(() => _i320.FirebaseStoragePhotoDataSource(
      gh<_i457.Reference>(instanceName: 'photosStorage')));
  gh.factory<_i283.AuthRemoteDataSource>(
      () => _i678.FirebaseAuthRemoteDataSource(gh<_i59.FirebaseAuth>()));
  gh.factory<_i179.PhotosRepository>(() => _i724.PhotosRepositoryImpl(
        gh<_i592.PhotoDataSource>(),
        gh<_i370.FilePickerDataSource>(),
      ));
  gh.factory<_i262.UploadPhotoUseCase>(
      () => _i262.UploadPhotoUseCase(gh<_i179.PhotosRepository>()));
  gh.factory<_i1061.TimeLineDataSource>(() =>
      _i1061.FirebaseTimelineRemoteDataSourceImpl(
          gh<_i974.CollectionReference<_i452.TimeLineModel>>(
              instanceName: 'timeline')));
  gh.factory<_i980.MomentRepository>(
      () => _i775.MomentRepositoryImpl(gh<_i771.MomentsDataSource>()));
  gh.factory<_i884.AuthRepository>(
      () => _i401.AuthRepositoryImpl(gh<_i283.AuthRemoteDataSource>()));
  gh.factory<_i465.GetMediaUseCase>(
      () => _i465.GetMediaUseCase(gh<_i179.PhotosRepository>()));
  gh.factory<_i393.IsUserAuthenticatedUseCase>(
      () => _i393.IsUserAuthenticatedUseCase(gh<_i884.AuthRepository>()));
  gh.factory<_i518.SignInUseCase>(
      () => _i518.SignInUseCase(gh<_i884.AuthRepository>()));
  gh.factory<_i480.SignUpUseCase>(
      () => _i480.SignUpUseCase(gh<_i884.AuthRepository>()));
  gh.factory<_i44.LogoutUseCase>(
      () => _i44.LogoutUseCase(gh<_i884.AuthRepository>()));
  gh.factory<_i184.TimeLineRepository>(() => _i294.TimeLineRepositoryImpl(
        momentsDataSource: gh<_i771.MomentsDataSource>(),
        timeLineDataSource: gh<_i1061.TimeLineDataSource>(),
      ));
  gh.factory<_i183.DeleteMomentsUseCase>(
      () => _i183.DeleteMomentsUseCase(gh<_i980.MomentRepository>()));
  gh.factory<_i272.UpdateMomentUseCase>(
      () => _i272.UpdateMomentUseCase(gh<_i980.MomentRepository>()));
  gh.factory<_i783.GetTimeLineFromEmailUseCase>(
      () => _i783.GetTimeLineFromEmailUseCase(
            gh<_i884.AuthRepository>(),
            gh<_i184.TimeLineRepository>(),
          ));
  gh.factory<_i522.ClearAllPhotosFromMomentUseCase>(() =>
      _i522.ClearAllPhotosFromMomentUseCase(gh<_i179.PhotosRepository>()));
  gh.factory<_i271.DeletePhotoUseCase>(
      () => _i271.DeletePhotoUseCase(gh<_i179.PhotosRepository>()));
  gh.factory<_i260.LoginBloc>(() => _i260.LoginBloc(
        gh<_i518.SignInUseCase>(),
        gh<_i393.IsUserAuthenticatedUseCase>(),
      ));
  gh.factory<_i773.SignUpBloc>(
      () => _i773.SignUpBloc(gh<_i480.SignUpUseCase>()));
  gh.factory<_i876.PhotosBloc>(
      () => _i876.PhotosBloc(gh<_i465.GetMediaUseCase>()));
  gh.factory<_i589.GetMomentsUseCase>(
      () => _i589.GetMomentsUseCase(gh<_i184.TimeLineRepository>()));
  gh.factory<_i283.CreateTimeLineUseCase>(() => _i283.CreateTimeLineUseCase(
        gh<_i184.TimeLineRepository>(),
        gh<_i884.AuthRepository>(),
      ));
  gh.factory<_i11.SelectTimeLineBloc>(() => _i11.SelectTimeLineBloc(
        gh<_i783.GetTimeLineFromEmailUseCase>(),
        gh<_i44.LogoutUseCase>(),
      ));
  gh.factory<_i663.RegisterMomentsUseCase>(() => _i663.RegisterMomentsUseCase(
        gh<_i980.MomentRepository>(),
        gh<_i184.TimeLineRepository>(),
      ));
  gh.factory<_i321.AddOrEditMomentBloc>(() => _i321.AddOrEditMomentBloc(
        gh<_i272.UpdateMomentUseCase>(),
        gh<_i663.RegisterMomentsUseCase>(),
        gh<_i262.UploadPhotoUseCase>(),
        gh<_i271.DeletePhotoUseCase>(),
      ));
  gh.factory<_i716.TimeLineBloc>(() => _i716.TimeLineBloc(
        gh<_i589.GetMomentsUseCase>(),
        gh<_i183.DeleteMomentsUseCase>(),
        gh<_i522.ClearAllPhotosFromMomentUseCase>(),
        gh<_i283.CreateTimeLineUseCase>(),
      ));
  return getIt;
}

class _$AppModules extends _i1023.AppModules {}

class _$FirebaseModule extends _i279.FirebaseModule {}
