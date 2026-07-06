import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:nossos_momentos/di/injection.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/domain/entities/moment.dart';
import '../../../time_line/domain/entity/time_line.dart';
import '../bloc/all_timelines_map_bloc.dart';
import '../utils/relationship_duration.dart';

/// Plots every moment that has coordinates on an OpenStreetMap map.
/// Tapping a pin shows a card; "Abrir" pops with the selected moment.
/// A chip row (shown only when there are 2+ timelines) filters by timeline.
class MomentsMapPage extends StatelessWidget {
  const MomentsMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllTimelinesMapBloc>(
      create: (_) => getIt<AllTimelinesMapBloc>()..add(FetchAllTimelinesMapEvent()),
      child: const _MomentsMapView(),
    );
  }
}

class _MomentsMapView extends StatefulWidget {
  const _MomentsMapView();

  @override
  State<_MomentsMapView> createState() => _MomentsMapViewState();
}

class _MomentsMapViewState extends State<_MomentsMapView> {
  Moment? _selected;

  /// null = show all timelines.
  String? _filteredTimelineId;

  void _setFilter(String? timelineId) {
    setState(() {
      _filteredTimelineId = timelineId;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllTimelinesMapBloc, AllTimelinesMapState>(
      builder: (context, state) {
        final palette = context.palette;
        final textTheme = Theme.of(context).textTheme;

        final appBar = AppBar(
          backgroundColor: palette.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Mapa dos momentos'),
        );

        if (state is AllTimelinesMapInitial || state is AllTimelinesMapLoading) {
          return Scaffold(
            appBar: appBar,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AllTimelinesMapError) {
          return Scaffold(
            appBar: appBar,
            body: Center(child: Text(state.message, style: textTheme.bodyMedium)),
          );
        }

        final timelines = state is AllTimelinesMapSuccess ? state.timelines : <TimeLine>[];
        final allLocated = state is AllTimelinesMapSuccess
            ? state.moments.where((m) => m.hasLocation).toList()
            : <Moment>[];

        final located = _filteredTimelineId == null
            ? allLocated
            : allLocated.where((m) => m.timelineId == _filteredTimelineId).toList();

        final showFilter = timelines.length > 1;

        if (located.isEmpty) {
          return Scaffold(
            appBar: appBar,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined, size: 48, color: palette.onSurfaceMuted),
                            kSpacerHeight16,
                            Text('Nenhum momento com localização', style: textTheme.titleMedium),
                            kSpacerHeight8,
                            Text(
                              'Adicione um local aos seus momentos para vê-los aqui.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showFilter)
                    _TimelineFilterBar(timelines: timelines, selectedId: _filteredTimelineId, onSelected: _setFilter),
                ],
              ),
            ),
          );
        }

        final points = located.map((m) => LatLng(m.latitude!, m.longitude!)).toList();
        final tileUrl = palette.isDark
            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
            : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

        return Scaffold(
          appBar: appBar,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCameraFit: CameraFit.coordinates(
                            coordinates: points,
                            padding: const EdgeInsets.all(60),
                            maxZoom: 15,
                          ),
                          onTap: (_, __) => setState(() => _selected = null),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: tileUrl,
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.nossosmomentos.app',
                          ),
                          SimpleAttributionWidget(
                            source: const Text('OpenStreetMap · CARTO'),
                            backgroundColor: palette.surface.withValues(alpha: 0.8),
                          ),
                          MarkerLayer(
                            markers: located.map((moment) {
                              final selected = identical(moment, _selected);
                              final size = selected ? 58.0 : 46.0;
                              return Marker(
                                point: LatLng(moment.latitude!, moment.longitude!),
                                width: size + 8,
                                height: size + 12,
                                alignment: Alignment.bottomCenter,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selected = moment),
                                  child: _MomentMarker(moment: moment, size: size, selected: selected),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      if (_selected != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 24,
                          child: _MomentMapCard(
                            moment: _selected!,
                            relationshipStartDate: timelines
                                .where((t) => t.id == _selected!.timelineId)
                                .firstOrNull
                                ?.relationshipStartDate,
                            onOpen: () => Navigator.pop(context, _selected),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showFilter)
                  _TimelineFilterBar(timelines: timelines, selectedId: _filteredTimelineId, onSelected: _setFilter),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal scrollable chip bar for filtering by timeline.
class _TimelineFilterBar extends StatelessWidget {
  const _TimelineFilterBar({required this.timelines, required this.selectedId, required this.onSelected});

  final List<TimeLine> timelines;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 48,
      color: palette.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _FilterChip(label: 'Todos', selected: selectedId == null, accentColor: null, onTap: () => onSelected(null)),
            ...timelines.map(
              (t) => _FilterChip(
                label: t.name,
                selected: selectedId == t.id,
                accentColor: t.accentColor,
                onTap: () => onSelected(t.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.accentColor, required this.onTap});

  final String label;
  final bool selected;
  final int? accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = accentColor != null ? Color(accentColor!) : palette.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
            border: Border.all(
              color: selected ? color : palette.onSurfaceMuted.withValues(alpha: 0.4),
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? color : palette.onSurfaceMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular media (first photo) with a type-colored icon fallback.
class _CircleMedia extends StatelessWidget {
  const _CircleMedia({required this.moment, required this.size});

  final Moment moment;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = moment.type.colors(context);
    final fallback = Container(
      color: colors.bg,
      alignment: Alignment.center,
      child: Icon(moment.type.icon, color: colors.accent, size: size * 0.42),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: moment.downloadUrlList.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: moment.downloadUrlList.first,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => fallback,
                placeholder: (_, __) => fallback,
              ),
      ),
    );
  }
}

class _MomentMarker extends StatelessWidget {
  const _MomentMarker({required this.moment, required this.size, required this.selected});

  final Moment moment;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ringColor = selected ? palette.primary : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.30), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          child: _CircleMedia(moment: moment, size: size),
        ),
        Transform.translate(
          offset: const Offset(0, -1),
          child: CustomPaint(size: const Size(12, 7), painter: _PinPointer(ringColor)),
        ),
      ],
    );
  }
}

class _PinPointer extends CustomPainter {
  const _PinPointer(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinPointer oldDelegate) => oldDelegate.color != color;
}

class _MomentMapCard extends StatelessWidget {
  const _MomentMapCard({required this.moment, required this.relationshipStartDate, required this.onOpen});

  final Moment moment;
  final DateTime? relationshipStartDate;
  final VoidCallback onOpen;

  bool get _hasTime => moment.dateTime.hour != 0 || moment.dateTime.minute != 0;

  String get _meta {
    final dt = moment.dateTime;
    return [
      moment.dateTimeFormatted,
      if (_hasTime) 'às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      if (moment.locationName.isNotEmpty) moment.locationName,
    ].join(' · ');
  }

  String? get _togetherLabel {
    final start = relationshipStartDate;
    if (start == null) return null;
    final startDay = DateTime(start.year, start.month, start.day);
    final momentDay = DateTime(moment.dateTime.year, moment.dateTime.month, moment.dateTime.day);
    if (momentDay.isBefore(startDay)) return null;
    return 'Juntos há ${RelationshipDuration.friendly(start, now: moment.dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final together = _togetherLabel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft(context),
      ),
      child: Row(
        children: [
          _CircleMedia(moment: moment, size: 46),
          kSpacerWidth12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(moment.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleMedium),
                Text(
                  _meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                ),
                if (together != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 12, color: palette.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          together,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(color: palette.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          kSpacerWidth8,
          TextButton(onPressed: onOpen, child: const Text('Abrir')),
        ],
      ),
    );
  }
}
