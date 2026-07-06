import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../core/presenter/widgets/background_gradient.dart';
import '../../../core/presenter/widgets/primary_button.dart';
import '../../../core/utils/share/capture_and_share.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/domain/entities/moment.dart';
import '../../../moment/domain/entities/moment_type.dart';
import '../utils/moment_counts.dart';

/// Couple-only "year in review" slideshow. No persistence: it ranks the loaded
/// moments of the selected year in memory and presents them as a swipeable
/// story (opening cover → top moments → shareable summary).
class YearInReviewPage extends StatefulWidget {
  const YearInReviewPage({
    super.key,
    required this.moments,
    this.coupleName = '',
    this.initialYear,
  });

  /// All moments already loaded in memory (e.g. `TimeLineBloc.allMoments`).
  final List<Moment> moments;

  /// Couple/timeline name shown on the cover slide.
  final String coupleName;

  /// Year to open with; defaults to the current year (or the most recent year
  /// that actually has moments).
  final int? initialYear;

  /// How many top moments to feature in the slideshow.
  static const int topCount = 10;

  /// Ranking weight per type: romantic moments shine first, then good, then bad.
  static int _typeWeight(MomentType type) {
    switch (type) {
      case MomentType.romantic:
        return 2;
      case MomentType.happy:
      case MomentType.good:
      case MomentType.cool:
        return 1;
      case MomentType.bad:
      case MomentType.sad:
      case MomentType.awful:
      case MomentType.disaster:
        return 0;
    }
  }

  @override
  State<YearInReviewPage> createState() => _YearInReviewPageState();
}

class _YearInReviewPageState extends State<YearInReviewPage> {
  final GlobalKey _summaryKey = GlobalKey();
  late List<int> _years;
  late int _selectedYear;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _years = widget.moments.map((m) => m.dateTime.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final current = widget.initialYear ?? DateTime.now().year;
    _selectedYear = _years.contains(current)
        ? current
        : (_years.isNotEmpty ? _years.first : current);
  }

  /// Moments of the selected year, ranked: favorites first, then by type
  /// (romantic > good > bad), then most recent.
  List<Moment> get _rankedMoments {
    final ofYear = widget.moments
        .where((m) => m.dateTime.year == _selectedYear)
        .toList()
      ..sort((a, b) {
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }
        final weight = YearInReviewPage._typeWeight(b.type)
            .compareTo(YearInReviewPage._typeWeight(a.type));
        if (weight != 0) return weight;
        return b.dateTime.compareTo(a.dateTime);
      });
    return ofYear.take(YearInReviewPage.topCount).toList();
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await captureAndShare(
        _summaryKey,
        text: 'Nossa retrospectiva de $_selectedYear',
        fileName: 'retrospectiva_$_selectedYear.png',
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível gerar a imagem.')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ranked = _rankedMoments;
    final counts = MomentCounts.from(
      widget.moments.where((m) => m.dateTime.year == _selectedYear).toList(),
    );

    final slides = <Widget>[
      _CoverSlide(year: _selectedYear, coupleName: widget.coupleName),
      ...ranked.map((m) => _MomentSlide(moment: m)),
      RepaintBoundary(
        key: _summaryKey,
        child: _SummarySlide(year: _selectedYear, counts: counts),
      ),
    ];

    return Stack(
      children: [
        const BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: const Text('Retrospectiva'),
            actions: [
              if (_years.length > 1) _buildYearSelector(context),
              kSpacerWidth8,
            ],
          ),
          body: SafeArea(
            top: false,
            child: counts.total == 0
                ? _EmptyState(year: _selectedYear)
                : Column(
                    children: [
                      Expanded(
                        child: CarouselSlider(
                          options: CarouselOptions(
                            viewportFraction: 0.86,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            height: double.infinity,
                          ),
                          items: slides
                              .map((s) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: s,
                                  ))
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: PrimaryButton(
                          label: 'Compartilhar resumo',
                          icon: Icons.ios_share_rounded,
                          onPressed: _sharing ? null : _share,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          isDense: true,
          borderRadius: BorderRadius.circular(AppRadii.input),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: palette.onSurface),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: palette.onSurface,
                fontWeight: FontWeight.w700,
              ),
          dropdownColor: palette.surface,
          items: _years
              .map((y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
              .toList(),
          onChanged: (year) {
            if (year != null) setState(() => _selectedYear = year);
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined, size: 48, color: palette.onSurfaceMuted),
            kSpacerHeight16,
            Text('Sem momentos em $year', style: textTheme.titleMedium),
            kSpacerHeight8,
            Text(
              'Registre memórias neste ano para ver a retrospectiva do grupo.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opening slide: "Retrospectiva {ano}" + the couple's name.
class _CoverSlide extends StatelessWidget {
  const _CoverSlide({required this.year, required this.coupleName});

  final int year;
  final String coupleName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.secondaryAccent],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 40),
          const Spacer(),
          Text(
            'Nosso ano',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          Text(
            '$year',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          if (coupleName.isNotEmpty) ...[
            kSpacerHeight12,
            Text(
              coupleName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Icon(Icons.swipe_left_rounded, color: Colors.white.withValues(alpha: 0.85), size: 18),
              kSpacerWidth8,
              Text(
                'Arraste para reviver',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A featured moment: hero photo (or themed gradient fallback) with title,
/// date and type overlaid — same visual language as [ShareableMomentCard].
class _MomentSlide extends StatelessWidget {
  const _MomentSlide({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final colors = moment.type.colors(context);
    final hero = moment.downloadUrlList.isNotEmpty ? moment.downloadUrlList.first : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hero != null)
            CachedNetworkImage(
              imageUrl: hero,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _SlideGradient(colors: colors, icon: moment.type.icon),
              placeholder: (_, __) => _SlideGradient(colors: colors, icon: moment.type.icon),
            )
          else
            _SlideGradient(colors: colors, icon: moment.type.icon),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: Row(
              children: [
                _Badge(
                  icon: moment.type.icon,
                  iconColor: colors.accent,
                  label: moment.type.label,
                ),
                if (moment.isFavorite) ...[
                  kSpacerWidth8,
                  const _Badge(
                    icon: Icons.favorite_rounded,
                    iconColor: Colors.white,
                    label: 'Favorito',
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moment.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  moment.dateTimeFormatted,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.iconColor, required this.label});

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Closing slide: the year's numbers. Rendered to a PNG for sharing.
class _SummarySlide extends StatelessWidget {
  const _SummarySlide({required this.year, required this.counts});

  final int year;
  final MomentCounts counts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.secondaryAccent],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo de $year',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          kSpacerHeight8,
          Text(
            '${counts.total}',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            counts.total == 1 ? 'momento registrado' : 'momentos registrados',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          kSpacerHeight24,
          _SummaryRow(
            icon: MomentType.romantic.icon,
            label: 'Românticos',
            value: counts.countOf(MomentType.romantic),
          ),
          _SummaryRow(
            icon: MomentType.good.icon,
            label: 'Bons',
            value: counts.countOf(MomentType.good),
          ),
          _SummaryRow(
            icon: Icons.favorite_rounded,
            label: 'Favoritos',
            value: counts.favorites,
          ),
          kSpacerHeight24,
          Row(
            children: [
              const Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
              kSpacerWidth8,
              Text(
                Strings.appName,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          kSpacerWidth12,
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          Text(
            '$value',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideGradient extends StatelessWidget {
  const _SlideGradient({required this.colors, required this.icon});

  final MomentColors colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.bg, colors.accent],
        ),
      ),
      child: Center(child: Icon(icon, size: 96, color: Colors.white.withValues(alpha: 0.85))),
    );
  }
}
