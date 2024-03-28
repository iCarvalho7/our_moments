import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';

@injectable
class GetMonthUseCase extends UseCase<String, NoParams> {
  @override
  String execute(NoParams params) {
    return TimeLineBloc.monthsName[DateTime.now().month - 1];
  }
}
