import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/domain/entities/moment.dart';
import '../widgets/memory_card.dart';

/// Lists moments that happened on this same calendar day in previous years.
/// Tapping a card pops with the selected moment.
class OnThisDayPage extends StatelessWidget {
  const OnThisDayPage({super.key, required this.moments});

  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final now = DateTime.now();

    final sorted = [...moments]..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Flatten into [yearsAgo header, cards...] grouped by year.
    final items = <Object>[];
    int? lastYear;
    for (final moment in sorted) {
      final year = moment.dateTime.year;
      if (year != lastYear) {
        items.add(now.year - year); // years-ago (int) acts as a header marker
        lastYear = year;
      }
      items.add(moment);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Neste dia'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is Moment) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, item),
              child: MemoryCard(moment: item),
            );
          }
          final yearsAgo = item as int;
          return _YearHeader(yearsAgo: yearsAgo);
        },
      ),
    );
  }
}

class _YearHeader extends StatelessWidget {
  const _YearHeader({required this.yearsAgo});

  final int yearsAgo;

  @override
  Widget build(BuildContext context) {
    final label = yearsAgo <= 0
        ? 'Este ano'
        : (yearsAgo == 1 ? 'Há 1 ano' : 'Há $yearsAgo anos');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
