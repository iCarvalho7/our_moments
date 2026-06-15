/// Builds a friendly "anos, meses e dias" description (pt-BR) of the time
/// elapsed between [start] and now — used by the "together" counter.
class RelationshipDuration {
  const RelationshipDuration._();

  static String friendly(DateTime start, {DateTime? now}) {
    final reference = now ?? DateTime.now();

    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(reference.year, reference.month, reference.day);

    if (from.isAfter(to)) return 'a partir de hoje';

    var years = to.year - from.year;
    var months = to.month - from.month;
    var days = to.day - from.day;

    if (days < 0) {
      months -= 1;
      final previousMonth = DateTime(to.year, to.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final parts = <String>[];
    if (years > 0) parts.add('$years ${years == 1 ? 'ano' : 'anos'}');
    if (months > 0) parts.add('$months ${months == 1 ? 'mês' : 'meses'}');
    if (days > 0) parts.add('$days ${days == 1 ? 'dia' : 'dias'}');

    if (parts.isEmpty) return 'hoje';
    if (parts.length == 1) return parts.first;

    final last = parts.removeLast();
    return '${parts.join(', ')} e $last';
  }
}
