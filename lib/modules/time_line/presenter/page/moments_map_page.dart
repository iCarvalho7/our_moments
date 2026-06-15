import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

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
                onOpen: () => Navigator.pop(context, _selected),
              ),
            ),
        ],
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
            : Image.network(
                moment.downloadUrlList.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
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
  const _MomentMapCard({required this.moment, required this.onOpen});

  final Moment moment;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

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
