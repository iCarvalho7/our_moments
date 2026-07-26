import 'package:flutter_test/flutter_test.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/time_line/gamification/domain/entity/momentum_progress.dart';

Moment _moment({
  required DateTime date,
  bool photo = false,
  bool location = false,
  String author = 'a@x.com',
}) {
  return Moment(
    id: date.toIso8601String() + author,
    dateTime: date,
    title: 'title',
    body: 'body',
    type: MomentType.good,
    monthDay: '${date.day}',
    month: '${date.month}',
    year: '${date.year}',
    downloadUrlList: photo ? ['https://example.com/p.jpg'] : const [],
    timelineId: 't1',
    latitude: location ? 1.0 : null,
    longitude: location ? 2.0 : null,
    author: author,
  );
}

void main() {
  group('MomentumProgress.from', () {
    test('empty moments produce a zeroed, level-1 snapshot', () {
      final p = MomentumProgress.from(const []);
      expect(p.totalMoments, 0);
      expect(p.points, 0);
      expect(p.level, 1);
      expect(p.currentStreakDays, 0);
      expect(p.longestStreakDays, 0);
      expect(p.unlockedAchievements, isEmpty);
    });

    test('points reward richer moments (photo + location)', () {
      final now = DateTime(2026, 7, 8);
      final p = MomentumProgress.from(
        [_moment(date: now, photo: true, location: true)],
        now: now,
      );
      // 10 base + 5 photo + 5 location.
      expect(p.points, 20);
      expect(p.totalMoments, 1);
      expect(p.achievements.firstWhere((a) => a.id == 'first_moment').unlocked, isTrue);
      expect(p.achievements.firstWhere((a) => a.id == 'first_trip').unlocked, isTrue);
    });

    test('counts a current streak of consecutive days ending today', () {
      final now = DateTime(2026, 7, 8);
      final p = MomentumProgress.from(
        [
          _moment(date: now),
          _moment(date: now.subtract(const Duration(days: 1))),
          _moment(date: now.subtract(const Duration(days: 2))),
        ],
        now: now,
      );
      expect(p.currentStreakDays, 3);
      expect(p.longestStreakDays, 3);
    });

    test('a gap breaks the current streak but keeps the longest run', () {
      final now = DateTime(2026, 7, 8);
      final p = MomentumProgress.from(
        [
          _moment(date: now),
          _moment(date: DateTime(2026, 6, 1)),
          _moment(date: DateTime(2026, 6, 2)),
          _moment(date: DateTime(2026, 6, 3)),
        ],
        now: now,
      );
      expect(p.currentStreakDays, 1);
      expect(p.longestStreakDays, 3);
    });

    test('week-streak achievement unlocks at 7 consecutive days', () {
      final now = DateTime(2026, 7, 8);
      final moments = [
        for (var i = 0; i < 7; i++) _moment(date: now.subtract(Duration(days: i))),
      ];
      final p = MomentumProgress.from(moments, now: now);
      expect(p.longestStreakDays, 7);
      expect(p.achievements.firstWhere((a) => a.id == 'week_streak').unlocked, isTrue);
    });

    test('personal-only achievement appears and unlocks with distinctTimelines', () {
      final now = DateTime(2026, 7, 8);
      // Without distinctTimelines: no "many_chapters" achievement in the catalog.
      final perStory = MomentumProgress.from([_moment(date: now)], now: now);
      expect(perStory.achievements.any((a) => a.id == 'many_chapters'), isFalse);

      // Personal aggregate across 3 timelines unlocks it.
      final personal = MomentumProgress.from(
        [_moment(date: now)],
        now: now,
        distinctTimelines: 3,
      );
      final chapters = personal.achievements.firstWhere((a) => a.id == 'many_chapters');
      expect(chapters.unlocked, isTrue);
    });
  });
}
