import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/location/domain/entity/place_suggestion.dart';
import 'package:nossos_momentos/modules/location/domain/use_case/reverse_geocode_use_case.dart';
import 'package:nossos_momentos/modules/location/domain/use_case/search_places_use_case.dart';

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
typedef _LocationPickerArgs = ({double? initialLatitude, double? initialLongitude, String? initialName});

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const LatLng _fallbackCenter = LatLng(-23.55052, -46.633308); // São Paulo

  final _searchPlacesUseCase = getIt<SearchPlacesUseCase>();
  final _reverseGeocodeUseCase = getIt<ReverseGeocodeUseCase>();
  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  double? _initialLatitude;
  double? _initialLongitude;
  late LatLng _center;
  bool _nameEditedManually = false;
  bool _resolvingName = false;
  bool _searching = false;
  bool _initialized = false;
  Timer? _debounce;
  Timer? _searchDebounce;
  List<PlaceSuggestion> _searchResults = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments as _LocationPickerArgs?;
    _initialLatitude = args?.initialLatitude;
    _initialLongitude = args?.initialLongitude;
    final initialName = args?.initialName;
    _center = (_initialLatitude != null && _initialLongitude != null)
        ? LatLng(_initialLatitude!, _initialLongitude!)
        : _fallbackCenter;
    _nameController.text = initialName ?? '';
    _nameEditedManually = (initialName ?? '').isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestLocationPermission());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchDebounce?.cancel();
    _nameController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (!mounted) return;
    // If no initial position was given and permission is available, jump there.
    if (_initialLatitude == null &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      _useCurrentLocation();
    }
  }

  void _scheduleReverseGeocode() {
    if (_nameEditedManually) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _reverseGeocode);
  }

  Future<void> _reverseGeocode() async {
    setState(() => _resolvingName = true);
    try {
      final result = await _reverseGeocodeUseCase.call(
        ReverseGeocodeParams(latitude: _center.latitude, longitude: _center.longitude),
      );
      if (mounted && !_nameEditedManually) {
        final name = result.data ?? '';
        if (name.isNotEmpty) _nameController.text = name;
      }
    } finally {
      if (mounted) setState(() => _resolvingName = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() => _searchResults = const []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 600), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().length < 3) return;
    setState(() => _searching = true);
    try {
      final result = await _searchPlacesUseCase.call(SearchPlacesParams(
        query: query,
        biasLatitude: _center.latitude,
        biasLongitude: _center.longitude,
      ));
      if (mounted) setState(() => _searchResults = result.data ?? const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectResult(PlaceSuggestion suggestion) {
    final latLng = LatLng(suggestion.latitude, suggestion.longitude);
    _nameEditedManually = false;
    _nameController.text = suggestion.name;
    _searchController.text = suggestion.name;
    FocusScope.of(context).unfocus();
    setState(() {
      _center = latLng;
      _searchResults = const [];
    });
    _mapController.move(latLng, 15);
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
        ? 'https://{s}.basemaps.cartocdn.com/rastertiles/dark_matter/{z}/{x}/{y}{r}.png'
        : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

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
              initialZoom: _initialLatitude != null ? 15 : 11,
              onPositionChanged: (camera, hasGesture) {
                _center = camera.center;
                if (hasGesture) _scheduleReverseGeocode();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                retinaMode: RetinaMode.isHighDensity(context),
                userAgentPackageName: 'com.nossosmomentos.app',
              ),
              SimpleAttributionWidget(
                source: const Text('OpenStreetMap · CARTO'),
                backgroundColor: palette.surface.withValues(alpha: 0.8),
              ),
            ],
          ),

          // Center pin — tip points at map center.
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on, size: 48, color: palette.primary),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 12),
                  child: FloatingActionButton(
                    heroTag: 'my_location',
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    onPressed: _useCurrentLocation,
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),
                _BottomPanel(
                  nameController: _nameController,
                  resolving: _resolvingName,
                  onNameChanged: () => _nameEditedManually = true,
                  onConfirm: _confirm,
                ),
              ],
            ),
          ),

          // Search bar + results — on top of everything including the bottom panel.
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Column(
              children: [
                _SearchBar(
                  controller: _searchController,
                  searching: _searching,
                  onChanged: _onSearchChanged,
                  onSubmit: () => _runSearch(_searchController.text.trim()),
                ),
                if (_searchResults.isNotEmpty)
                  _SearchResults(
                    results: _searchResults,
                    onSelect: _selectResult,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.searching,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool searching;
  final ValueChanged<String> onChanged;
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
        onChanged: onChanged,
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

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.onSelect});

  final List<PlaceSuggestion> results;
  final void Function(PlaceSuggestion) onSelect;

  static IconData _iconFor(String type) {
    switch (type) {
      case 'restaurant':
      case 'cafe':
      case 'bar':
      case 'fast_food':
      case 'food_court':
        return Icons.restaurant_outlined;
      case 'hotel':
      case 'lodging':
      case 'motel':
        return Icons.hotel_outlined;
      case 'bus_station':
      case 'transit_station':
      case 'ferry_terminal':
        return Icons.directions_bus_outlined;
      case 'airport':
        return Icons.flight_outlined;
      case 'hospital':
      case 'doctor':
      case 'pharmacy':
        return Icons.local_hospital_outlined;
      case 'school':
      case 'university':
        return Icons.school_outlined;
      case 'museum':
      case 'tourist_attraction':
      case 'amusement_park':
        return Icons.museum_outlined;
      case 'park':
      case 'campground':
      case 'beach':
        return Icons.park_outlined;
      case 'shopping_mall':
      case 'supermarket':
      case 'store':
        return Icons.shopping_bag_outlined;
      case 'locality':
      case 'administrative_area_level_1':
      case 'administrative_area_level_2':
        return Icons.location_city_outlined;
    }
    return Icons.place_outlined;
  }

  /// Extracts "City - State, Country" from a Google formatted address.
  static String _cityHint(String address) {
    final parts = address.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length <= 1) return address;
    return parts.sublist(parts.length < 3 ? 0 : parts.length - 2).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        boxShadow: AppShadows.soft(context),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: results.length,
        separatorBuilder: (_, __) => Divider(height: 1, indent: 56, color: palette.outline),
        itemBuilder: (context, index) {
          final s = results[index];
          final hint = _cityHint(s.address);
          return InkWell(
            onTap: () => onSelect(s),
            borderRadius: index == 0
                ? const BorderRadius.vertical(top: Radius.circular(AppRadii.input))
                : index == results.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(AppRadii.input))
                    : BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(_iconFor(s.primaryType), color: palette.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
