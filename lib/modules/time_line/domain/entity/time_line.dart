import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../presenter/bloc/time_line_bloc.dart';

class TimeLine {
  final Timestamp createdDate;
  final List<String> emails;
  final String id;
  final List<String> momentIds;

  /// Emails of every owner of the timeline. The first entry is the original
  /// creator; ownership can be shared with other members.
  final List<String> owners;

  /// When the couple's relationship started (used by the "together" counter).
  final DateTime? relationshipStartDate;

  /// Optional date the relationship ended (freezes the "together" counter).
  final DateTime? relationshipEndDate;

  /// Optional custom name and accent color (theming) for the timeline.
  final String name;
  final int? accentColor;

  /// Premium entitlement mirror (the couple's, persisted on the timeline doc).
  final bool isPremium;

  /// Expiry of the premium entitlement; null means lifetime.
  final DateTime? premiumUntil;

  /// Couple cover photo (Firebase Storage URL); empty keeps the default header.
  final String coverPhotoUrl;

  /// Per-email nicknames for the couple, keyed by the member's email.
  final Map<String, String> nicknames;

  /// When true, moments cannot be created/edited with a date after the
  /// relationship end date.
  final bool enforceEndDate;

  /// Per-email role for every member. Keys are email addresses; values are
  /// 'owner', 'editor' or 'viewer'. Absent entries default to 'editor'.
  final Map<String, String> roles;

  /// How members may edit each other's moments:
  /// - 'collaborative' — any editor/owner can edit any moment;
  /// - 'individual'    — an editor can only edit the moments they authored.
  /// Owners are unaffected (they can always edit any moment).
  final String momentEditPolicy;

  /// Present only while a multi-owner timeline deletion is pending consensus.
  /// Keys are owner emails; a value of `true` means that owner approved the
  /// deletion. Null (or empty) means no deletion is in progress.
  final Map<String, bool>? pendingDeletion;

  TimeLine({
    required this.createdDate,
    required this.emails,
    required this.id,
    required this.momentIds,
    required this.owners,
    this.relationshipStartDate,
    this.relationshipEndDate,
    this.name = '',
    this.accentColor,
    this.isPremium = false,
    this.premiumUntil,
    this.coverPhotoUrl = '',
    this.nicknames = const {},
    this.enforceEndDate = false,
    this.roles = const {},
    this.momentEditPolicy = 'individual',
    this.pendingDeletion,
  });

  /// Returns a copy with the given fields overridden. New TimeLine fields MUST
  /// be threaded here so partial updates never silently drop them.
  ///
  /// Note: [pendingDeletion] is nullable, so passing `null` can't distinguish
  /// "clear it" from "leave unchanged". To clear it, pass
  /// [clearPendingDeletion] `true` (which wins over [pendingDeletion]).
  TimeLine copyWith({
    Timestamp? createdDate,
    List<String>? emails,
    String? id,
    List<String>? momentIds,
    List<String>? owners,
    DateTime? relationshipStartDate,
    DateTime? relationshipEndDate,
    String? name,
    int? accentColor,
    bool? isPremium,
    DateTime? premiumUntil,
    String? coverPhotoUrl,
    Map<String, String>? nicknames,
    bool? enforceEndDate,
    Map<String, String>? roles,
    String? momentEditPolicy,
    Map<String, bool>? pendingDeletion,
    bool clearPendingDeletion = false,
  }) {
    return TimeLine(
      createdDate: createdDate ?? this.createdDate,
      emails: emails ?? this.emails,
      id: id ?? this.id,
      momentIds: momentIds ?? this.momentIds,
      owners: owners ?? this.owners,
      relationshipStartDate: relationshipStartDate ?? this.relationshipStartDate,
      relationshipEndDate: relationshipEndDate ?? this.relationshipEndDate,
      name: name ?? this.name,
      accentColor: accentColor ?? this.accentColor,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      nicknames: nicknames ?? this.nicknames,
      enforceEndDate: enforceEndDate ?? this.enforceEndDate,
      roles: roles ?? this.roles,
      momentEditPolicy: momentEditPolicy ?? this.momentEditPolicy,
      pendingDeletion:
          clearPendingDeletion ? null : (pendingDeletion ?? this.pendingDeletion),
    );
  }

  /// Effective premium: flag is on AND not expired (lifetime when null).
  bool get isActivePremium =>
      isPremium && (premiumUntil == null || premiumUntil!.isAfter(DateTime.now()));

  String get momentsAmount => '${momentIds.length} momentos';

  String get dateMonth {
    String day = DateFormat('dd', 'pt_BR').format(createdDate.toDate());
    String month = TimeLineBloc.monthsName[createdDate.toDate().month - 1];

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
    final copy = List<String>.from(emails);
    copy.remove(email);
    copy.insert(0, email);
    return copy;
  }
}
