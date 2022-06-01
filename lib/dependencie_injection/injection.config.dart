// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i7;
import '../modules/time_line/domain/use_case/get_moments_use_case.dart' as _i9;
import '../modules/time_line/external/firebase/firebase_timeline_data_sourse.dart'
    as _i6;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i5;
import '../modules/time_line/infra/models/moment_model.dart' as _i4;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i8;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i10;
import 'modules/firebase_modules.dart'
    as _i11; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i3.CollectionReference<_i4.MomentModel>>(
      () => firebaseModule.momentsDBRef,
      instanceName: 'momentsDBRef');
  gh.factory<_i5.TimeLineDataSource>(() => _i6.FirebaseTimeLineDataSource(
      get<_i3.CollectionReference<_i4.MomentModel>>(
          instanceName: 'momentsDBRef')));
  gh.factory<_i7.TimeLineRepository>(() =>
      _i8.TimeLineRepositoryImpl(dataSource: get<_i5.TimeLineDataSource>()));
  gh.factory<_i9.GetMomentsUseCase>(
      () => _i9.GetMomentsUseCaseImpl(get<_i7.TimeLineRepository>()));
  gh.factory<_i10.TimeLineBloc>(
      () => _i10.TimeLineBloc(get<_i9.GetMomentsUseCase>()));
  return get;
}

class _$FirebaseModule extends _i11.FirebaseModule {}
