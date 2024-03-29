import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../presenter/bloc/time_line_bloc.dart';

class TimeLine {
  final Timestamp createdDate;
  final List<String> emails;
  final String id;
  final List<String> momentIds;

  TimeLine({
    required this.createdDate,
    required this.emails,
    required this.id,
    required this.momentIds,
  });

  String get momentsAmount => '${momentIds.length} momentos';

  String get dateMonth {
    String day = DateFormat('dd', 'pt_BR').format(createdDate.toDate());
    String month = TimeLineBloc.monthsName[createdDate.toDate().month];

    return '$day $month de ${createdDate.toDate().year}';
  }

  List<String> get emailsFormatted {
    if (emails.length > 1) {
      return emails.sublist(0, 2);
    } else {
      return emails;
    }
  }
}
