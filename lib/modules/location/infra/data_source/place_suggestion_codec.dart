import 'dart:convert';

import '../../domain/entity/place_suggestion.dart';

/// JSON (de)serialization for [PlaceSuggestion], shared by the local stores
/// that persist places (search history and favorites).
extension PlaceSuggestionCodec on PlaceSuggestion {
  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'primaryType': primaryType,
      };

  String encode() => jsonEncode(toMap());
}

/// Type used to flag places the user authored by hand (vs. picked from search).
const String kCustomPlaceType = 'custom';

/// Two places are considered the same entry when name and coordinates match.
bool samePlace(PlaceSuggestion a, PlaceSuggestion b) =>
    a.name == b.name && a.latitude == b.latitude && a.longitude == b.longitude;

PlaceSuggestion? decodePlaceSuggestion(String raw) {
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return PlaceSuggestion(
      name: map['name'] as String,
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      primaryType: map['primaryType'] as String? ?? '',
    );
  } catch (_) {
    return null;
  }
}

List<PlaceSuggestion> decodePlaceSuggestions(List<String> raw) =>
    raw.map(decodePlaceSuggestion).whereType<PlaceSuggestion>().toList();
