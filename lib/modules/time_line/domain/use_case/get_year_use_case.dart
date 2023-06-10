import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../../presenter/bloc/time_line_bloc.dart';

@injectable
class GetYearUseCase extends UseCase<String, NoParams> {
  @override
  String execute(NoParams params) {
    return TimeLineBloc.enabledYears.firstWhere((e) => e == DateTime.now().year.toString());
  }
}
