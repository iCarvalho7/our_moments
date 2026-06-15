import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../presenter/bloc/time_line_bloc.dart';

class TimeLine {
  final Timestamp createdDate;
  final List<String> emails;
  final String id;
  final List<String> momentIds;
  final String owner;

  /// When the couple's relationship started (used by the "together" counter).
  final DateTime? relationshipStartDate;

  TimeLine({
    required this.createdDate,
    required this.emails,
    required this.id,
    required this.momentIds,
    required this.owner,
    this.relationshipStartDate,
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

  List<String> emailsUserFirst(String email) {
    emails.remove(email);
    emails.insert(0, email);
    return emails;
  }
}
