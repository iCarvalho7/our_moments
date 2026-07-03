import 'package:flutter/material.dart';

import '../../../core/presenter/widgets/background_gradient.dart';
import '../../../core/presenter/widgets/primary_app_bar.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/domain/entities/moment.dart';
import '../../../moment/domain/entities/moment_type.dart';
import '../utils/moment_counts.dart';

/// Couple-only statistics over the timeline's moments. Pure read/count widget:
/// receives the loaded moments and computes totals in memory (no repository).
class CoupleStatsPage extends StatelessWidget {
  const CoupleStatsPage({super.key, required this.moments});

  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PrimaryAppBar(title: 'Estatísticas do grupo'),
          body: SafeArea(
            top: false,
            child: moments.isEmpty
                ? _EmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TotalCard(total: moments.length),
                        kSpacerHeight24,
                        _SectionTitle(title: 'Por tipo de momento'),
                        kSpacerHeight12,
                        _TypeBreakdown(moments: moments),
                        kSpacerHeight24,
                        _SectionTitle(title: 'Por autor'),
                        kSpacerHeight12,
                        _AuthorBreakdown(moments: moments),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights_outlined, size: 48, color: palette.onSurfaceMuted),
          kSpacerHeight16,
          Text('Ainda não há momentos', style: textTheme.titleMedium),
          kSpacerHeight8,
          Text(
            'Registre memórias para ver as estatísticas do grupo.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

/// Hero card with the couple's total moment count.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [palette.primary, palette.secondaryAccent]),
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              kSpacerWidth8,
              Text(
                'Momentos do grupo',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          kSpacerHeight12,
          Text(
            '$total',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            total == 1 ? 'momento registrado' : 'momentos registrados',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

/// Count of moments per [MomentType], each row with the type's themed color.
class _TypeBreakdown extends StatelessWidget {
  const _TypeBreakdown({required this.moments});

  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    final counts = MomentCounts.from(moments);
    final total = counts.total;

    return Column(
      children: MomentType.values.map((type) {
        final count = counts.countOf(type);
        final colors = type.colors(context);
        return _StatRow(
          leading: Icon(type.icon, color: colors.accent, size: 20),
          leadingBackground: colors.bg,
          label: type.label,
          count: count,
          total: total,
          barColor: colors.accent,
        );
      }).toList(),
    );
  }
}

/// Count of moments grouped by author email. Empty author -> "Desconhecido".
class _AuthorBreakdown extends StatelessWidget {
  const _AuthorBreakdown({required this.moments});

  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final total = moments.length;

    final counts = <String, int>{};
    for (final moment in moments) {
      final key = moment.author.isEmpty ? 'Desconhecido' : moment.author;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        final label = entry.key;
        return _StatRow(
          leading: Text(
            label.isNotEmpty ? label[0].toUpperCase() : '?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          leadingBackground: palette.primarySoft,
          label: label,
          count: entry.value,
          total: total,
          barColor: palette.primary,
        );
      }).toList(),
    );
  }
}

/// A single statistic row: leading badge, label, share bar and count.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.leading,
    required this.leadingBackground,
    required this.label,
    required this.count,
    required this.total,
    required this.barColor,
  });

  final Widget leading;
  final Color leadingBackground;
  final String label;
  final int count;
  final int total;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final fraction = total == 0 ? 0.0 : count / total;
    final percent = (fraction * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: leadingBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: leading,
              ),
              kSpacerWidth12,
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              kSpacerWidth12,
              Text(
                '$count',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              kSpacerWidth8,
              Text(
                '($percent%)',
                style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
              ),
            ],
          ),
          kSpacerHeight12,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: palette.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
