import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/select_type_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/select_type_state.dart';

@injectable
class SelectTypeBloc extends Bloc<SelectMomentTypeEvent, SelectTypeState> {
  SelectTypeBloc()
      : super(SelectTypeStateLoaded(selectedItems: defaultSelectedList)) {
    on<SelectTypeEventSelectType>(_handleSelectType);
  }

  FutureOr<void> _handleSelectType(
    SelectTypeEventSelectType event,
    Emitter<SelectTypeState> emit,
  ) {
     List<bool> currentList = [false, false, false];
    currentList[event.index] = true;

    emit(
      SelectTypeStateLoaded(selectedItems: currentList),
    );
  }

  static final defaultSelectedList = [false, false, false];
}
