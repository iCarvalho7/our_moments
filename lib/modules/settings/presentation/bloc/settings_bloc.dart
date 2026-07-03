import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/entity/result.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/add_email_use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/delete_account_use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/delete_email_use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/leave_timeline_use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/reauthenticate_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_time_line_from_id_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/delete_time_line_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/update_access_levels_use_case.dart'
    show UpdateRolesUseCase, UpdateRolesParams;
import 'package:nossos_momentos/modules/time_line/domain/use_case/update_couple_header_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/update_relationship_end_date_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/update_time_line_details_use_case.dart';

import '../../domain/use_case/get_current_user_use_case.dart';

part 'settings_event.dart';

part 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this.addEmailUseCase,
    this.deleteEmailUseCase,
    this.getCurrentUserUseCase,
    this._getTimeLineFromIdUseCase,
    this._updateTimeLineDetailsUseCase,
    this._updateCoupleHeaderUseCase,
    this._updateRelationshipEndDateUseCase,
    this._updateRolesUseCase,
    this._deleteTimeLineUseCase,
    this._deleteAccountUseCase,
    this._reauthenticateUseCase,
    this._leaveTimelineUseCase,
  ) : super(SettingsLoading(timeLine: null, email: null)) {
    on<FetchEmailEvent>(_init);
    on<AddEmailEvent>(_addEmail);
    on<DeleteEmailEvent>(_deleteEmail);
    on<UpdateTimeLineDetailsEvent>(_updateDetails);
    on<UpdateCoupleHeaderEvent>(_updateCoupleHeader);
    on<UpdateRelationshipEndDateEvent>(_updateRelationshipEndDate);
    on<UpdateAccessLevelEvent>(_updateAccessLevel);
    on<DeleteTimeLineEvent>(_deleteTimeLine);
    on<LeaveTimelineEvent>(_leaveTimeline);
    on<DeleteAccountEvent>(_deleteAccount);
    on<ReauthenticateAndDeleteAccountEvent>(_reauthenticateAndDeleteAccount);
  }

  final AddEmailUseCase addEmailUseCase;
  final DeleteEmailUseCase deleteEmailUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetTimeLineFromIdUseCase _getTimeLineFromIdUseCase;
  final UpdateTimeLineDetailsUseCase _updateTimeLineDetailsUseCase;
  final UpdateCoupleHeaderUseCase _updateCoupleHeaderUseCase;
  final UpdateRelationshipEndDateUseCase _updateRelationshipEndDateUseCase;
  final UpdateRolesUseCase _updateRolesUseCase;
  final DeleteTimeLineUseCase _deleteTimeLineUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final ReauthenticateUseCase _reauthenticateUseCase;
  final LeaveTimelineUseCase _leaveTimelineUseCase;

  FutureOr<void> _init(
    FetchEmailEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final res = getCurrentUserUseCase.call(NoParams.instance);
    final timelineRes = await _getTimeLineFromIdUseCase.call(event.timeLineId);

    if (res.isSuccess && res.data != null && timelineRes.isSuccess) {
      emit(SettingsSuccess(timeLine: timelineRes.data!, email: res.data!.email));
    }
  }

  FutureOr<void> _addEmail(
    AddEmailEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));

    final res = await addEmailUseCase.call(EmailParam(email: event.email, timeline: state.timeLine!));
    if (res.isError || res.data == null) {
      emit(SettingsError(timeLine: state.timeLine, email: state.email));
      return;
    }
    emit(SettingsSuccess(timeLine: res.data!, email: state.email));
  }

  FutureOr<void> _deleteEmail(
    DeleteEmailEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));

    final res = await deleteEmailUseCase.call(EmailParam(email: event.email, timeline: state.timeLine!));
    if (res.isError) {
      emit(SettingsError(timeLine: state.timeLine, email: state.email));
      return;
    }
    emit(SettingsSuccess(timeLine: res.data!, email: state.email));
  }

  FutureOr<void> _updateDetails(
    UpdateTimeLineDetailsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final res = await _updateTimeLineDetailsUseCase.call(UpdateTimeLineDetailsParams(
      timeline: state.timeLine!,
      name: event.name,
      accentColor: event.accentColor,
    ));
    if (res.isSuccess && res.data != null) {
      emit(SettingsSuccess(timeLine: res.data!, email: state.email));
    }
  }

  FutureOr<void> _updateCoupleHeader(
    UpdateCoupleHeaderEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));

    final res = await _updateCoupleHeaderUseCase.call(UpdateCoupleHeaderParams(
      timeline: state.timeLine!,
      nicknames: event.nicknames,
      localCoverPath: event.localCoverPath,
      keepCoverUrl: event.keepCoverUrl,
    ));
    if (res.isSuccess && res.data != null) {
      emit(SettingsSuccess(timeLine: res.data!, email: state.email));
    } else {
      emit(SettingsError(timeLine: state.timeLine, email: state.email));
    }
  }

  FutureOr<void> _updateRelationshipEndDate(
    UpdateRelationshipEndDateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final res = await _updateRelationshipEndDateUseCase.call(
      UpdateRelationshipEndDateParams(
        timeline: state.timeLine!,
        date: event.date,
        enforceEndDate: event.enforceEndDate,
      ),
    );
    if (res.isSuccess && res.data != null) {
      emit(SettingsSuccess(timeLine: res.data!, email: state.email));
    }
  }

  FutureOr<void> _updateAccessLevel(
    UpdateAccessLevelEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = Map<String, String>.from(state.timeLine!.roles);
    current[event.email] = event.level;
    final res = await _updateRolesUseCase.call(UpdateRolesParams(
      timeline: state.timeLine!,
      roles: current,
    ));
    if (res.isSuccess && res.data != null) {
      emit(SettingsSuccess(timeLine: res.data!, email: state.email));
    }
  }

  FutureOr<void> _deleteTimeLine(
    DeleteTimeLineEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));
    final res = await _deleteTimeLineUseCase.call(state.timeLine!.id);
    if (res.isError) {
      emit(SettingsError(timeLine: state.timeLine, email: state.email));
      return;
    }
    emit(SettingsTimeLineDeleted(timeLine: state.timeLine, email: state.email));
  }

  FutureOr<void> _leaveTimeline(
    LeaveTimelineEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));
    final res = await _leaveTimelineUseCase.call(LeaveTimelineParams(
      timeLine: state.timeLine!,
      userEmail: state.email!,
      deleteAuthoredMoments: event.deleteAuthoredMoments,
    ));
    if (res.isError) {
      emit(SettingsError(timeLine: state.timeLine, email: state.email));
      return;
    }
    // Reuses the "timeline gone from this user's view" state to route away.
    emit(SettingsTimeLineDeleted(timeLine: state.timeLine, email: state.email));
  }

  FutureOr<void> _deleteAccount(
    DeleteAccountEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));
    final res = await _deleteAccountUseCase.call(NoParams.instance);
    _emitDeleteAccountResult(res, emit);
  }

  FutureOr<void> _reauthenticateAndDeleteAccount(
    ReauthenticateAndDeleteAccountEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));

    final reauth = await _reauthenticateUseCase.call(event.password);
    if (reauth.isError) {
      // Wrong password or reauth failure: let the user try again.
      emit(SettingsReauthRequired(timeLine: state.timeLine, email: state.email));
      return;
    }

    final res = await _deleteAccountUseCase.call(NoParams.instance);
    _emitDeleteAccountResult(res, emit);
  }

  /// Maps the result of a delete-account attempt to a state. A
  /// `requires-recent-login` error asks the UI to reauthenticate and retry.
  void _emitDeleteAccountResult(
    Result<void> res,
    Emitter<SettingsState> emit,
  ) {
    if (res.isSuccess) {
      emit(SettingsAccountDeleted(timeLine: state.timeLine, email: state.email));
      return;
    }

    final exception = res.exception;
    if (exception is FirebaseAuthException &&
        exception.code == 'requires-recent-login') {
      emit(SettingsReauthRequired(timeLine: state.timeLine, email: state.email));
      return;
    }

    emit(SettingsAccountDeleteError(timeLine: state.timeLine, email: state.email));
  }
}
