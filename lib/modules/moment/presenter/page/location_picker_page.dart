import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/theme/app_theme.dart';

/// Result returned by [LocationPickerPage].
class PickedLocation {
  const PickedLocation({required this.latitude, required this.longitude, required this.name});

  final double latitude;
  final double longitude;
  final String name;
}

/// Full-screen map picker styled to match the app: search a place, drag the
/// centered pin, or jump to the device's location. Tiles follow the theme
/// (light/dark) and the name is auto-filled (reverse geocoding) yet editable.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.initialLatitude, this.initialLongitude, this.initialName});

  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialName;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const LatLng _fallbackCenter = LatLng(-23.55052, -46.633308); // São Paulo

  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _center;
  bool _nameEditedManually = false;
  bool _resolvingName = false;
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _center = (widget.initialLatitude != null && widget.initialLongitude != null)
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _fallbackCenter;
    _nameController.text = widget.initialName ?? '';
    _nameEditedManually = (widget.initialName ?? '').isNotEmpty;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _scheduleReverseGeocode() {
    if (_nameEditedManually) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _reverseGeocode);
  }

  Future<void> _reverseGeocode() async {
    setState(() => _resolvingName = true);
    try {
      final marks = await placemarkFromCoordinates(_center.latitude, _center.longitude);
      if (marks.isNotEmpty && !_nameEditedManually) {
        _nameController.text = _formatPlacemark(marks.first);
      }
    } catch (_) {
      // No result / offline / unsupported on web — keep the current name.
    } finally {
      if (mounted) setState(() => _resolvingName = false);
    }
  }

  String _formatPlacemark(Placemark p) {
    final parts = [p.name, p.subLocality, p.locality]
        .where((e) => e != null && e.trim().isNotEmpty)
        .map((e) => e!.trim())
        .toSet()
        .toList();
    return parts.isEmpty ? '' : parts.take(2).join(', ');
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _searching = true);
    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('Nenhum lugar encontrado.')));
        return;
      }
      final latLng = LatLng(results.first.latitude, results.first.longitude);
      _nameEditedManually = false;
      _nameController.text = query;
      setState(() => _center = latLng);
      _mapController.move(latLng, 15);
      _scheduleReverseGeocode();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Busca de endereço indisponível.')));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        messenger.showSnackBar(const SnackBar(content: Text('Ative a localização do dispositivo.')));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(const SnackBar(content: Text('Permissão de localização negada.')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      _nameEditedManually = false;
      setState(() => _center = latLng);
      _mapController.move(latLng, 16);
      _scheduleReverseGeocode();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Não foi possível obter sua localização.')));
    }
  }

  void _confirm() {
    Navigator.pop(
      context,
      PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        name: _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tileUrl = palette.isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Escolher local'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: widget.initialLatitude != null ? 15 : 11,
              onPositionChanged: (camera, hasGesture) {
                _center = camera.center;
                if (hasGesture) _scheduleReverseGeocode();
              },
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
            ],
          ),

          // Center pin (its tip points at the map center).
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on, size: 48, color: palette.primary),
              ),
            ),
          ),

          // Search bar.
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: _SearchBar(
              controller: _searchController,
              searching: _searching,
              onSubmit: _search,
            ),
          ),

          // Jump to current location.
          Positioned(
            right: 16,
            bottom: 190,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              onPressed: _useCurrentLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomPanel(
              nameController: _nameController,
              resolving: _resolvingName,
              onNameChanged: () => _nameEditedManually = true,
              onConfirm: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.searching, required this.onSubmit});

  final TextEditingController controller;
  final bool searching;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        boxShadow: AppShadows.soft(context),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSubmit(),
        decoration: InputDecoration(
          filled: false,
          hintText: 'Buscar endereço ou lugar...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: searching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(icon: const Icon(Icons.arrow_forward_rounded), onPressed: onSubmit),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.nameController,
    required this.resolving,
    required this.onNameChanged,
    required this.onConfirm,
  });

  final TextEditingController nameController;
  final bool resolving;
  final VoidCallback onNameChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppShadows.soft(context),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => onNameChanged(),
            decoration: InputDecoration(
              hintText: 'Nome do lugar (ex: Nosso restaurante)',
              prefixIcon: const Icon(Icons.place_outlined),
              suffixIcon: resolving
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
          ),
          kSpacerHeight12,
          ElevatedButton(onPressed: onConfirm, child: const Text('Usar este local')),
        ],
      ),
    );
  }
}
