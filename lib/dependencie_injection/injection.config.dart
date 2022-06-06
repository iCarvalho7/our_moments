// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:cloud_firestore/cloud_firestore.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../modules/add_moment/presenter/bloc/add_date_bloc.dart' as _i3;
import '../modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart'
    as _i4;
import '../modules/add_moment/presenter/bloc/add_photo_bloc.dart' as _i7;
import '../modules/add_moment/presenter/bloc/select_type_bloc.dart' as _i8;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i11;
import '../modules/time_line/domain/use_case/get_moments_use_case.dart' as _i13;
import '../modules/time_line/external/firebase/firebase_timeline_data_sourse.dart'
    as _i10;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i9;
import '../modules/time_line/infra/models/time_line_moment_model.dart' as _i6;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i12;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i14;
import 'modules/firebase_modules.dart'
    as _i15; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i3.AddDateBloc>(() => _i3.AddDateBloc());
  gh.factory<_i4.AddOrEditMomentBloc>(() => _i4.AddOrEditMomentBloc());
  gh.factory<_i5.CollectionReference<_i6.TimeLineMomentModel>>(
      () => firebaseModule.momentsDBRef,
      instanceName: 'momentsDBRef');
  gh.factory<_i7.HistoryBloc>(() => _i7.HistoryBloc());
  gh.factory<_i8.SelectTypeBloc>(() => _i8.SelectTypeBloc());
  gh.factory<_i9.TimeLineDataSource>(() => _i10.FirebaseTimeLineDataSource(
      get<_i5.CollectionReference<_i6.TimeLineMomentModel>>(
          instanceName: 'momentsDBRef')));
  gh.factory<_i11.TimeLineRepository>(() =>
      _i12.TimeLineRepositoryImpl(dataSource: get<_i9.TimeLineDataSource>()));
  gh.factory<_i13.GetMomentsUseCase>(
      () => _i13.GetMomentsUseCaseImpl(get<_i11.TimeLineRepository>()));
  gh.factory<_i14.TimeLineBloc>(
      () => _i14.TimeLineBloc(get<_i13.GetMomentsUseCase>()));
  return get;
}

class _$FirebaseModule extends _i15.FirebaseModule {}
