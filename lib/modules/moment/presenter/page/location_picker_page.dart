import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/location/domain/entity/place_suggestion.dart';
import 'package:nossos_momentos/modules/location/domain/use_case/reverse_geocode_use_case.dart';
import 'package:nossos_momentos/modules/location/domain/use_case/search_places_use_case.dart';
import 'package:nossos_momentos/modules/location/infra/data_source/favorite_places_store.dart';
import 'package:nossos_momentos/modules/location/infra/data_source/location_search_history_store.dart';
import 'package:nossos_momentos/modules/location/infra/data_source/place_suggestion_codec.dart';

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
  final _historyStore = getIt<LocationSearchHistoryStore>();
  final _favoritesStore = getIt<FavoritePlacesStore>();
  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

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
  List<PlaceSuggestion> _history = const [];
  List<PlaceSuggestion> _favorites = const [];
  bool _searchFocused = false;

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
    _searchFocus.addListener(() {
      if (mounted) setState(() => _searchFocused = _searchFocus.hasFocus);
    });
    _loadSaved();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestLocationPermission());
  }

  Future<void> _loadSaved() async {
    final results = await Future.wait([
      _historyStore.recent(),
      _favoritesStore.favorites(),
    ]);
    if (mounted) {
      setState(() {
        _history = results[0];
        _favorites = results[1];
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchDebounce?.cancel();
    _nameController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
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
    _rememberPlace(suggestion);
  }

  Future<void> _rememberPlace(PlaceSuggestion suggestion) async {
    await _historyStore.add(suggestion);
    await _loadSaved();
  }

  Future<void> _removeFromHistory(PlaceSuggestion suggestion) async {
    await _historyStore.remove(suggestion);
    await _loadSaved();
  }

  Future<void> _clearHistory() async {
    if (!await _confirmClear('Limpar buscas recentes?')) return;
    await _historyStore.clear();
    await _loadSaved();
  }

  Future<void> _clearFavorites() async {
    if (!await _confirmClear('Remover todos os favoritos?')) return;
    await _favoritesStore.clear();
    await _loadSaved();
  }

  Future<bool> _confirmClear(String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Limpar')),
        ],
      ),
    );
    return confirmed ?? false;
  }

  bool _isFavorite(PlaceSuggestion suggestion) =>
      _favorites.any((f) => samePlace(f, suggestion));

  Future<void> _toggleFavorite(PlaceSuggestion suggestion) async {
    if (_isFavorite(suggestion)) {
      await _favoritesStore.remove(suggestion);
    } else {
      await _favoritesStore.add(suggestion);
    }
    await _loadSaved();
  }

  /// Builds a suggestion from the current pin + typed name. When the user typed
  /// the name themselves it is flagged as a custom, user-authored place.
  PlaceSuggestion _currentPinSuggestion() {
    final name = _nameController.text.trim();
    return PlaceSuggestion(
      name: name,
      address: name,
      latitude: _center.latitude,
      longitude: _center.longitude,
      primaryType: _nameEditedManually ? kCustomPlaceType : '',
    );
  }

  Future<void> _toggleFavoriteCurrent() async {
    final suggestion = _currentPinSuggestion();
    if (suggestion.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome ao local antes de favoritar.')),
      );
      return;
    }
    // A custom place is also recorded in history so it resurfaces easily.
    if (suggestion.primaryType == kCustomPlaceType && !_isFavorite(suggestion)) {
      await _historyStore.add(suggestion);
    }
    await _toggleFavorite(suggestion);
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
    final suggestion = _currentPinSuggestion();
    if (suggestion.name.isNotEmpty) {
      // Fire-and-forget: the page is about to close, so don't await the reload.
      _historyStore.add(suggestion);
    }
    Navigator.pop(
      context,
      PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        name: suggestion.name,
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
                  isFavorite: _isFavorite(_currentPinSuggestion()),
                  onNameChanged: () => setState(() => _nameEditedManually = true),
                  onToggleFavorite: _toggleFavoriteCurrent,
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
                  focusNode: _searchFocus,
                  searching: _searching,
                  onChanged: _onSearchChanged,
                  onSubmit: () => _runSearch(_searchController.text.trim()),
                ),
                if (_searchResults.isNotEmpty)
                  _SearchResults(
                    results: _searchResults,
                    onSelect: _selectResult,
                    isFavorite: _isFavorite,
                    onToggleFavorite: _toggleFavorite,
                  )
                else if (_searchFocused &&
                    _searchController.text.trim().length < 3 &&
                    (_favorites.isNotEmpty || _history.isNotEmpty))
                  _SavedPlaces(
                    favorites: _favorites,
                    recents: _history,
                    onSelect: _selectResult,
                    onToggleFavorite: _toggleFavorite,
                    onRemoveRecent: _removeFromHistory,
                    onClearFavorites: _clearFavorites,
                    onClearRecents: _clearHistory,
                    isFavorite: _isFavorite,
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
    required this.focusNode,
    required this.searching,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
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
        focusNode: focusNode,
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

IconData _iconForPlace(String type) {
  switch (type) {
    case kCustomPlaceType:
      return Icons.push_pin_outlined;
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
String _cityHint(String address) {
  final parts = address.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (parts.length <= 1) return address;
  return parts.sublist(parts.length < 3 ? 0 : parts.length - 2).join(', ');
}

/// A single place row: leading category icon, name + hint, a favorite toggle
/// and (for recents) a remove button.
class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.place,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onRemove,
    this.borderRadius = BorderRadius.zero,
  });

  final PlaceSuggestion place;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemove;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
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
              child: Icon(_iconForPlace(place.primaryType), color: palette.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    _cityHint(place.address),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: isFavorite ? palette.primary : palette.onSurfaceMuted,
              ),
              onPressed: onToggleFavorite,
              tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
            ),
            if (onRemove != null)
              IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: palette.onSurfaceMuted),
                onPressed: onRemove,
                tooltip: 'Remover',
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.results,
    required this.onSelect,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final List<PlaceSuggestion> results;
  final void Function(PlaceSuggestion) onSelect;
  final bool Function(PlaceSuggestion) isFavorite;
  final void Function(PlaceSuggestion) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
          return _PlaceRow(
            place: s,
            onTap: () => onSelect(s),
            isFavorite: isFavorite(s),
            onToggleFavorite: () => onToggleFavorite(s),
            borderRadius: index == 0
                ? const BorderRadius.vertical(top: Radius.circular(AppRadii.input))
                : index == results.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(AppRadii.input))
                    : BorderRadius.zero,
          );
        },
      ),
    );
  }
}

/// Locally-stored favorites and recent picks, shown when the search box is
/// focused and empty.
class _SavedPlaces extends StatelessWidget {
  const _SavedPlaces({
    required this.favorites,
    required this.recents,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onRemoveRecent,
    required this.onClearFavorites,
    required this.onClearRecents,
    required this.isFavorite,
  });

  final List<PlaceSuggestion> favorites;
  final List<PlaceSuggestion> recents;
  final void Function(PlaceSuggestion) onSelect;
  final void Function(PlaceSuggestion) onToggleFavorite;
  final void Function(PlaceSuggestion) onRemoveRecent;
  final VoidCallback onClearFavorites;
  final VoidCallback onClearRecents;
  final bool Function(PlaceSuggestion) isFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        boxShadow: AppShadows.soft(context),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 4),
        children: [
          if (favorites.isNotEmpty) ...[
            _SectionHeader(icon: Icons.star_rounded, label: 'Favoritos', onClear: onClearFavorites),
            for (final s in favorites)
              _PlaceRow(
                place: s,
                onTap: () => onSelect(s),
                isFavorite: true,
                onToggleFavorite: () => onToggleFavorite(s),
                onRemove: () => onToggleFavorite(s),
              ),
          ],
          if (recents.isNotEmpty) ...[
            _SectionHeader(icon: Icons.history_rounded, label: 'Buscas recentes', onClear: onClearRecents),
            for (final s in recents)
              _PlaceRow(
                place: s,
                onTap: () => onSelect(s),
                isFavorite: isFavorite(s),
                onToggleFavorite: () => onToggleFavorite(s),
                onRemove: () => onRemoveRecent(s),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label, this.onClear});

  final IconData icon;
  final String label;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: palette.onSurfaceMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: palette.onSurfaceMuted),
          ),
          const Spacer(),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: palette.onSurfaceMuted,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Limpar'),
            ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.nameController,
    required this.resolving,
    required this.isFavorite,
    required this.onNameChanged,
    required this.onToggleFavorite,
    required this.onConfirm,
  });

  final TextEditingController nameController;
  final bool resolving;
  final bool isFavorite;
  final VoidCallback onNameChanged;
  final VoidCallback onToggleFavorite;
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
          Row(
            children: [
              Expanded(
                child: TextField(
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
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onToggleFavorite,
                icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                color: isFavorite ? palette.primary : palette.onSurfaceMuted,
                tooltip: isFavorite ? 'Remover dos favoritos' : 'Salvar como favorito',
              ),
            ],
          ),
          kSpacerHeight12,
          ElevatedButton(onPressed: onConfirm, child: const Text('Usar este local')),
        ],
      ),
    );
  }
}
