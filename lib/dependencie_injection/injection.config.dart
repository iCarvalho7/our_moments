// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:cloud_firestore/cloud_firestore.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/add_moment/domain/repository/register_moment_repository.dart'
    as _i10;
import '../modules/add_moment/domain/use_case/register_moments_use_case.dart'
    as _i12;
import '../modules/add_moment/external/firebase/firebase_moments_data_source.dart'
    as _i9;
import '../modules/add_moment/infra/data_source/moments_data_source.dart'
    as _i8;
import '../modules/add_moment/infra/models/moment_model.dart' as _i6;
import '../modules/add_moment/infra/repository/register_moment_repository_impl.dart'
    as _i11;
import '../modules/add_moment/presenter/bloc/add_date_bloc.dart' as _i3;
import '../modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart'
    as _i18;
import '../modules/add_moment/presenter/bloc/add_photo_bloc.dart' as _i7;
import '../modules/add_moment/presenter/bloc/select_type_bloc.dart' as _i13;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i16;
import '../modules/time_line/domain/use_case/get_moments_use_case.dart' as _i19;
import '../modules/time_line/external/firebase/firebase_timeline_data_sourse.dart'
    as _i15;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i14;
import '../modules/time_line/infra/models/time_line_moment_model.dart' as _i5;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i17;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i20;
import 'modules/firebase_modules.dart'
    as _i21; // ignore_for_file: unnecessary_lambdas

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
  gh.factory<_i7.HistoryBloc>(() => _i7.HistoryBloc());
  gh.factory<_i8.MomentsDataSource>(() => _i9.FirebaseMomentsDataSource(
      get<_i4.CollectionReference<_i6.MomentModel>>(
          instanceName: 'momentsDBParam')));
  gh.factory<_i10.RegisterMomentRepository>(
      () => _i11.RegisterMomentRepositoryImpl(get<_i8.MomentsDataSource>()));
  gh.factory<_i12.RegisterMomentsUseCase>(
      () => _i12.RegisterMomentsUseCase(get<_i10.RegisterMomentRepository>()));
  gh.factory<_i13.SelectTypeBloc>(() => _i13.SelectTypeBloc());
  gh.factory<_i14.TimeLineDataSource>(() => _i15.FirebaseTimeLineDataSource(
      get<_i4.CollectionReference<_i5.TimeLineMomentModel>>(
          instanceName: 'timelineDBParam')));
  gh.factory<_i16.TimeLineRepository>(() =>
      _i17.TimeLineRepositoryImpl(dataSource: get<_i14.TimeLineDataSource>()));
  gh.factory<_i18.AddOrEditMomentBloc>(
      () => _i18.AddOrEditMomentBloc(get<_i12.RegisterMomentsUseCase>()));
  gh.factory<_i19.GetMomentsUseCase>(
      () => _i19.GetMomentsUseCaseImpl(get<_i16.TimeLineRepository>()));
  gh.factory<_i20.TimeLineBloc>(
      () => _i20.TimeLineBloc(get<_i19.GetMomentsUseCase>()));
  return get;
}

class _$FirebaseModule extends _i21.FirebaseModule {}
