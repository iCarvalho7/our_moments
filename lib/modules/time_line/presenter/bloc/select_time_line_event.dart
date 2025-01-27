part of 'select_time_line_bloc.dart';


sealed class SelectTimeLineEvent {}

class SelectTimeLineEventFetchAll extends SelectTimeLineEvent {}

class SelectTimeLineEventLogout extends SelectTimeLineEvent {}
