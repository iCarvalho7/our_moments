import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'add_date_event.dart';
part 'add_date_state.dart';

@injectable
class AddDateBloc extends Bloc<AddDateEvent, AddDateState> {
  AddDateBloc() : super(const AddDateStateInit(defaultText)) {
    on<AddDateEventAddDateToLabel>(_updateDateLabel);
  }

  FutureOr<void> _updateDateLabel(
    AddDateEventAddDateToLabel event,
    Emitter<AddDateState> emit,
  ) {
    emit(
      AddDateStateInit(event.dateLabel),
    );
  }

  static const String defaultText = 'Adicionar Data +';
}
