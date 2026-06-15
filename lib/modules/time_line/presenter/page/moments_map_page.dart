import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/domain/entities/moment.dart';

/// Plots every moment that has coordinates on an OpenStreetMap map.
/// Tapping a pin shows a card; "Abrir" pops with the selected moment.
class MomentsMapPage extends StatefulWidget {
  const MomentsMapPage({super.key, required this.moments});

  final List<Moment> moments;

  @override
  State<MomentsMapPage> createState() => _MomentsMapPageState();
}

class _MomentsMapPageState extends State<MomentsMapPage> {
  late final List<Moment> _located =
      widget.moments.where((m) => m.hasLocation).toList();
  Moment? _selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final appBar = AppBar(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      title: const Text('Mapa dos momentos'),
    );

    if (_located.isEmpty) {
      return Scaffold(
        appBar: appBar,
        body: Center(
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
      );
    }

    final points = _located.map((m) => LatLng(m.latitude!, m.longitude!)).toList();
    final tileUrl = palette.isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    return Scaffold(
      appBar: appBar,
      body: Stack(
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
                markers: _located.map((moment) {
                  final colors = moment.type.colors(context);
                  final selected = identical(moment, _selected);
                  return Marker(
                    point: LatLng(moment.latitude!, moment.longitude!),
                    width: 48,
                    height: 48,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = moment),
                      child: Icon(
                        Icons.location_on,
                        size: selected ? 48 : 38,
                        color: colors.accent,
                      ),
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
                onOpen: () => Navigator.pop(context, _selected),
              ),
            ),
        ],
      ),
    );
  }
}

class _MomentMapCard extends StatelessWidget {
  const _MomentMapCard({required this.moment, required this.onOpen});

  final Moment moment;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final colors = moment.type.colors(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft(context),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colors.bg, shape: BoxShape.circle),
            child: Icon(moment.type.icon, size: 20, color: colors.accent),
          ),
          kSpacerWidth12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  moment.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                Text(
                  moment.locationName.isNotEmpty
                      ? '${moment.dateTimeFormatted} · ${moment.locationName}'
                      : moment.dateTimeFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                ),
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
