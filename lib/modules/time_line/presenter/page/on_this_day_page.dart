import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/domain/entities/moment.dart';
import '../widgets/memory_card.dart';

/// Lists "memories" — moments from this same day (or, as a fallback, this same
/// month) in previous years. Tapping a card pops with the selected moment.
///
/// [scopeLabel] describes what is being shown (e.g. "15 de junho" or "junho").
/// When [moments] is empty, a friendly empty state is shown instead.
class OnThisDayPage extends StatelessWidget {
  const OnThisDayPage({super.key, required this.moments, this.scopeLabel});

  final List<Moment> moments;
  final String? scopeLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Neste dia'),
      ),
      body: moments.isEmpty ? _EmptyState(scopeLabel: scopeLabel) : _buildList(context, now),
    );
  }

  Widget _buildList(BuildContext context, DateTime now) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scopeLabel != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'Memórias de $scopeLabel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.onSurfaceMuted,
                  ),
            ),
          ),
        Expanded(
          child: ListView.builder(
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
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.scopeLabel});

  final String? scopeLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded, color: palette.primary, size: 38),
            ),
            kSpacerHeight24,
            Text(
              'Ainda não há memórias',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            kSpacerHeight8,
            Text(
              scopeLabel != null
                  ? 'Quando vocês registrarem momentos de $scopeLabel em outros anos, eles vão aparecer aqui para reviver. 💛'
                  : 'Quando vocês tiverem memórias deste dia em outros anos, elas vão aparecer aqui para reviver. 💛',
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
