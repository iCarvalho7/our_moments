import '../../../moment/domain/entities/moment.dart';
import '../../../moment/domain/entities/moment_type.dart';

/// Pure, in-memory tallies over a list of [Moment]s. Shared by the couple
/// statistics screen and the "year in review" summary so the counting logic
/// lives in one place (no repository, no persistence).
class MomentCounts {
  const MomentCounts({
    required this.total,
    required this.byType,
    required this.favorites,
  });

  /// Total number of moments.
  final int total;

  /// Count of moments per [MomentType] (every type present, even with 0).
  final Map<MomentType, int> byType;

  /// Count of favorited moments.
  final int favorites;

  factory MomentCounts.from(List<Moment> moments) {
    final byType = <MomentType, int>{
      for (final type in MomentType.values) type: 0,
    };
    var favorites = 0;
    for (final moment in moments) {
      byType[moment.type] = (byType[moment.type] ?? 0) + 1;
      if (moment.isFavorite) favorites++;
    }
    return MomentCounts(
      total: moments.length,
      byType: byType,
      favorites: favorites,
    );
  }

  int countOf(MomentType type) => byType[type] ?? 0;
}
